# utl_http_multipart
Simple package to send files and parameters to an url using POST multipart form-data.

# Usage
declare
	v_req utl_http.req;
	v_resp utl_http.resp;
	v_parts utl_http_multipart.parts := utl_http_multipart.parts();

begin
	...
  
	utl_http_multipart.add_file(v_parts, 'binaryfile', 'binaryfile', 'application/octet-stream', bfile_key);
	utl_http_multipart.add_param(v_parts, 'type', 'PKCS12');
	utl_http_multipart.add_param(v_parts, 'alias', 'rafael');

	utl_http_multipart.add_file(v_parts, 'pdf', '123.pdf', 'application/pdf', bfile_pdf);
	utl_http_multipart.add_param(v_parts, 'name', 'rafael');

	v_req := utl_http.begin_request('http://yourdomain.com/upload/send', 'POST', 'HTTP/1.1');

	utl_http_multipart.send(v_req, v_parts);

	v_resp := utl_http.get_response(v_req);
	if(v_resp.status_code <> UTL_HTTP.HTTP_OK) then
	
	...
end