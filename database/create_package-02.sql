create or replace package api_front is

procedure InsertMessage(
  v_msg_id   				   out number,    
	v_msg_name					 		 varchar2,
	v_msg_email					 		 varchar2,
	v_msg_phone					 		 varchar2,
	v_msg_value					 		 varchar2,
  v_result         		 out number     -- operation code:
	                                    --     0 - success
  	                                  --    -1 - error (exception in REPORT_LOG) 
);

end api_front;
/
create or replace package body api_front is

procedure trace(
  v_log_record   					 t_messages.report_message%type
)is
begin
  insert into t_report_log(report_id, report_message) values (s_report_log.nextval, v_log_record);
	commit;
end;

procedure InsertMessage(
  v_msg_id   				 	 out number,    
	v_msg_name					 		 varchar2,
	v_msg_email					 		 varchar2,
	v_msg_phone					 		 varchar2,
	v_msg_value					 		 varchar2,
  v_result         		 out number     -- operation code:
	                                    --     0 - success
  	                                  --    -1 - error (exception in REPORT_LOG) 
) is
begin
  v_result := 0;
	select s_messages.nextval into v_msg_id from dual;
	insert into t_messages(msg_id, msg_name, msg_email, msg_phone, msg_value) values(v_msg_id, v_msg_name, v_msg_email, v_msg_phone, v_msg_value);
exception
  when others then
    rollback;
    v_result := -1;
    trace('InsertMessage('||v_msg_value||'). '||replace(dbms_utility.format_error_stack||'. '||dbms_utility.format_error_backtrace, chr(10), ''));
end;

end api_front;
/
