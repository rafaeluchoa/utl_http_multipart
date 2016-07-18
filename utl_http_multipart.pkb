create or replace package body utl_http_multipart as

  /**
    * @author Rafael Uchôa
    * @email rafael@naskar.com.br
    */

  v_newline constant varchar2(10) := chr(13) || chr(10);
  v_boundary constant varchar2(60) := '---------------------------30837156019033';
  v_end constant varchar2(10) := '--';

  procedure add_param(
    p_parts in out parts,
    p_name in varchar2,
    p_value in varchar2
  ) as
    v_part part;
  begin
  
    v_part.ds_header := 
      'Content-Disposition: form-data; name="' || p_name || '"' || v_newline || v_newline
    ;
    v_part.ds_value := p_value;
    
    p_parts.EXTEND();
    p_parts(p_parts.last) := v_part;
    
  end add_param;

  procedure add_file(
    p_parts in out parts,
    p_name in varchar2,
    p_filename varchar2,
    p_content_type varchar2,
    p_blob bfile
  ) as
    v_part part;
  begin
    v_part.ds_header := 
      'Content-Disposition: form-data; name="' || p_name || '"; filename="' || p_filename || '"' || v_newline ||
      'Content-Type: ' || p_content_type || v_newline || v_newline
    ;
    v_part.ds_blob := p_blob;
  
    p_parts.EXTEND();
    p_parts(p_parts.last) := v_part;
    
  end add_file;
  
  procedure send(
    p_req in out utl_http.req,
    p_parts in out parts
  ) as
    v_length number := 0;
    v_length_bo number := length(v_boundary);
    v_length_nl number := length(v_newline);
    v_length_end number := length(v_end);
    
    v_step pls_integer := 12000;
    v_count pls_integer := 0;
  begin
  
    -- calculate the content-length
    v_length := v_length + v_length_end + v_length_bo + v_length_nl;
    for i in p_parts.first .. p_parts.last loop
      v_length := v_length + length(p_parts(i).ds_header);
      
      if(p_parts(i).ds_blob is not null) then
        v_length := v_length + dbms_lob.getlength(p_parts(i).ds_blob);
      else
        v_length := v_length + length(p_parts(i).ds_value);
      end if;      
      v_length := v_length + v_length_nl;
      v_length := v_length + v_length_end + v_length_bo;
      
      if(i != p_parts.last) then
        v_length := v_length + v_length_nl;
      end if;
      
    end loop;
    v_length := v_length + v_length_end + v_length_nl;
  
    utl_http.set_header(p_req, 'Content-Type', 'multipart/form-data; boundary=' || v_boundary);
    utl_http.set_header(p_req, 'Content-Length', v_length);
    
    utl_http.write_raw(p_req, utl_raw.cast_to_raw(v_end));
    utl_http.write_raw(p_req, utl_raw.cast_to_raw(v_boundary));
    utl_http.write_raw(p_req, utl_raw.cast_to_raw(v_newline));
    
    -- write parts
    for i in p_parts.first .. p_parts.last loop
      utl_http.write_raw(p_req, utl_raw.cast_to_raw(p_parts(i).ds_header));
      
      if(p_parts(i).ds_blob is not null) then
      
        dbms_lob.open(p_parts(i).ds_blob, dbms_lob.lob_readonly);
        v_count := trunc((dbms_lob.getlength(p_parts(i).ds_blob) - 1)/v_step);
        for j in 0..v_count loop
          utl_http.write_raw(p_req, dbms_lob.substr(p_parts(i).ds_blob, v_step, j * v_step + 1));
        end loop;
        dbms_lob.close(p_parts(i).ds_blob);
        
      else
        utl_http.write_raw(p_req, utl_raw.cast_to_raw(p_parts(i).ds_value));
        
      end if;
      
      utl_http.write_raw(p_req, utl_raw.cast_to_raw(v_newline));
      utl_http.write_raw(p_req, utl_raw.cast_to_raw(v_end));
      utl_http.write_raw(p_req, utl_raw.cast_to_raw(v_boundary));
      
      if(i != p_parts.last) then
        utl_http.write_raw(p_req, utl_raw.cast_to_raw(v_newline));
      end if;
    end loop;
    
    utl_http.write_raw(p_req, utl_raw.cast_to_raw(v_end));
    utl_http.write_raw(p_req, utl_raw.cast_to_raw(v_newline));
    
  end send;

end utl_http_multipart;
/
