create or replace package api_front is

procedure InsertMessage(
  v_msg_id   				   out number,
	v_msg_name					 		 varchar2,
	v_msg_email					 		 varchar2,
	v_msg_phone					 		 varchar2,
	v_msg_value					 		 varchar2,
  v_result         		 out number     -- operation code:
	                                    --     0 - success
	                                    --     1 - name is absent
	                                    --     2 - email is absent
	                                    --     3 - email is incorrect
	                                    --     4 - message is absent
  	                                  --    -1 - unknown error (exception in REPORT_LOG)
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

function CheckInputEMail(
  v_email            			 varchar2
) return number 										  -- operation code:
							                				--     0 - success
                                		  --     1 - invalid email
                                		  --    -1 - unknown error (exception in REPORT_LOG)
is
  v_count            			 number := 0;
  v_result           			 number := 0;
begin
	begin
	  select count(regexp_substr(trim(v_email), '^[a-zA-Z0-9!#$%''\*\+-/=\?^_`\{|\}~]+@[a-zA-Z0-9._%-]+\.[a-zA-Z]{2,8}$')) into v_count from dual;
  	v_result := 1 - v_count;
	exception
  	when others then
    	v_result := -1;
	    trace('CheckInputEMail('||v_email||'). '||replace(dbms_utility.format_error_stack||'. '||dbms_utility.format_error_backtrace, chr(10), ''));
	end;
  return v_result;
end;

procedure GetUserJWTData(
  v_refresh_token	 in out	t_users.user_refresh_token%type,
  v_user_id     			out	t_users.user_id%type,
  v_basket_id					out	t_baskets.basket_id%type,
  v_user_name   			out	t_contacts.contact_name%type,
  v_result      			out	number    -- operation code:
                                    --     0 - success
                                    --    -1 - unknown error (exception in REPORT_LOG)
) is
begin
  v_result 				:= 0;

	begin
		select u.user_id, u.auth_type_id, u.user_type_id, u.lang_id, nvl(u.user_blog, 0), u.user_is_mobile, u.user_hash, c.contact_name
   	into v_user_id, v_auth_type_id, v_user_type_id, v_lang_id, v_user_blog, v_is_mobile_, v_user_hash, v_user_name
    from t_users u, t_baskets b
 	  where 
   		u.user_id = c.user_id(+) and lower(u.user_cookie) = lower(v_refresh_token)
    fetch first 1 rows only;
	exception
		when no_data_found then
			InsertUser(v_user_id, v_result);
     	if v_result != 0 then return; end if; 
	end;

	GetUserBasket(v_basket_id, v_user_id, v_result);
  if v_result != 0 then return; end if; 

	GetUserWishlist(v_wishlist_id, v_user_id, v_result);
  if v_result != 0 then return; end if; 

	UpdateUserToken(v_user_id, v_refresh_token, v_result);
 	if v_result != 0 then return; end if; 

	UpdateContactCheck(v_contact_m_id, v_contact_s_id, v_user_id, v_result);
 	if v_result != 0 then return; end if; 

exception
  when others then
    rollback;
    v_result := -1;
    api_utils.add_log('GetUserData('||v_ip||', '||v_agent||', '||v_hash_uid||', '||v_is_mobile||', '||v_refresh_token||', '||v_hash_uid||'). '||replace(dbms_utility.format_error_stack||'. '||dbms_utility.format_error_backtrace, chr(10), ''));

end;

procedure InsertMessage(
  v_msg_id   				 	 out number,
	v_msg_name					 		 varchar2,
	v_msg_email					 		 varchar2,
	v_msg_phone					 		 varchar2,
	v_msg_value					 		 varchar2,
  v_result         		 out number     -- operation code:
	                                    --     0 - success
	                                    --     1 - name is absent
	                                    --     2 - email is absent
	                                    --     3 - email is incorrect
	                                    --     4 - message is absent
  	                                  --    -1 - unknown error (exception in REPORT_LOG)
) is
begin
  v_result := 0;
  
  if v_msg_name is null then
	  v_result := 1;
    return;
  end if;
  if v_msg_email is null then
	  v_result := 2;
    return;
  end if;
  if CheckInputEMail(v_msg_email) != 0 then
	  v_result := 3;
    return;
  end if;
  if v_msg_value is null then
	  v_result := 4;
    return;
  end if;
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
