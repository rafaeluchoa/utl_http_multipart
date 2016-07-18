create or replace package utl_http_multipart as 

  /**
    * @author Rafael Uchôa
    * @email rafael@naskar.com.br
    */

  type part is record (
    ds_header varchar2(2048),
    ds_value varchar2(1024),
    ds_blob bfile
  );
  
  type parts is table of part;
  
  procedure add_param(
    p_parts in out parts,
    p_name in varchar2,
    p_value in varchar2
  );
  
  procedure add_file(
    p_parts in out parts,
    p_name in varchar2,
    p_filename varchar2,
    p_content_type varchar2,
    p_blob bfile
  );
  
  procedure send(
    p_req in out utl_http.req,
    p_parts in out parts
  );
  

end utl_http_multipart;
/
