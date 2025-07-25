-- test cases for oupc_pl-sql procedures

declare
    v_error_code number;
    v_error_message varchar2(4000);
    v_count number;
    v_job_name varchar2(100) := 'test_cleanup_job';
    v_job_action varchar2(4000) := 'begin dbms_utility.exec_ddl_statement(''truncate table temp_table''); end;';
    v_start_date timestamp := systimestamp;
    v_repeat_interval varchar2(100) := 'freq=daily; byhour=1; byminute=0; bysecond=0';
begin
    -- test 1: log_audit success case
    begin
        util_pkg.log_audit(
            p_table_name => 'employees',
            p_operation => 'insert',
            p_record_id => 1,
            p_details => 'test audit log entry'
        );
        select count(*) into v_count
        from audit_log
        where table_name = 'employees' and operation = 'insert' and record_id = 1;
        if v_count = 1 then
            dbms_output.put_line('test 1: log_audit success - passed');
        else
            dbms_output.put_line('test 1: log_audit success - failed');
        end if;
    exception
        when others then
            dbms_output.put_line('test 1: log_audit success - error: ' || sqlerrm);
    end;
    
    -- test 2: log_audit failure case (null table_name)
    begin
        util_pkg.log_audit(
            p_table_name => null,
            p_operation => 'update',
            p_record_id => 2,
            p_details => 'should fail due to null table_name'
        );
        dbms_output.put_line('test 2: log_audit failure - failed (should have raised exception)');
    exception
        when others then
            if sqlcode = -20001 then
                dbms_output.put_line('test 2: log_audit failure - passed');
            else
                dbms_output.put_line('test 2: log_audit failure - error: ' || sqlerrm);
            end if;
    end;
    
    -- test 3: log_error success case
    begin
        util_pkg.log_error(
            p_module_name => 'test_module',
            p_error_code => -20001,
            p_error_message => 'test error occurred',
            p_stack_trace => 'test stack trace'
        );
        select count(*) into v_count
        from error_log
        where module_name = 'test_module' and error_code = -20001;
        if v_count = 1 then
            dbms_output.put_line('test 3: log_error success - passed');
        else
            dbms_output.put_line('test 3: log_error success - failed');
        end if;
    exception
        when others then
            dbms_output.put_line('test 3: log_error success - error: ' || sqlerrm);
    end;
    
    -- test 4: log_error failure case (null module_name)
    begin
        util_pkg.log_error(
            p_module_name => null,
            p_error_code => -20002,
            p_error_message => 'should fail due to null module_name',
            p_stack_trace => 'test stack trace'
        );
        dbms_output.put_line('test 4: log_error failure - failed (should have raised exception)');
    exception
        when others then
            if sqlcode = -20003 then
                dbms_output.put_line('test 4: log_error failure - passed');
            else
                dbms_output.put_line('test 4: log_error failure - error: ' || sqlerrm);
            end if;
    end;
    
    -- test 5: send_email_alert success case
    begin
        util_pkg.send_email_alert(
            p_recipient => 'admin@example.com',
            p_subject => 'test alert',
            p_message => 'this is a test email alert'
        );
        dbms_output.put_line('test 5: send_email_alert success - passed (assuming email sent)');
    exception
        when others then
            dbms_output.put_line('test 5: send_email_alert success - error: ' || sqlerrm);
    end;
    
    -- test 6: send_email_alert failure case (null recipient)
    begin
        util_pkg.send_email_alert(
            p_recipient => null,
            p_subject => 'test alert',
            p_message => 'should fail due to null recipient'
        );
        dbms_output.put_line('test 6: send_email_alert failure - failed (should have raised exception)');
    exception
        when others then
            if sqlcode = -20005 then
                dbms_output.put_line('test 6: send_email_alert failure - passed');
            else
                dbms_output.put_line('test 6: send_email_alert failure - error: ' || sqlerrm);
            end if;
    end;
    
    -- test 7: create_scheduled_job success case
    begin
        util_pkg.create_scheduled_job(
            p_job_name => v_job_name,
            p_job_action => v_job_action,
            p_start_date => v_start_date,
            p_repeat_interval => v_repeat_interval
        );
        select count(*) into v_count
        from user_scheduler_jobs
        where job_name = v_job_name;
        if v_count = 1 then
            dbms_output.put_line('test 7: create_scheduled_job success - passed');
        else
            dbms_output.put_line('test 7: create_scheduled_job success - failed');
        end if;
    exception
        when others then
            dbms_output.put_line('test 7: create_scheduled_job success - error: ' || sqlerrm);
    end;
    
    -- test 8: create_scheduled_job failure case (null job_name)
    begin
        util_pkg.create_scheduled_job(
            p_job_name => null,
            p_job_action => v_job_action,
            p_start_date => v_start_date,
            p_repeat_interval => v_repeat_interval
        );
        dbms_output.put_line('test 8: create_scheduled_job failure - failed (should have raised exception)');
    exception
        when others then
            if sqlcode = -20007 then
                dbms_output.put_line('test 8: create_scheduled_job failure - passed');
            else
                dbms_output.put_line('test 8: create_scheduled_job failure - error: ' || sqlerrm);
            end if;
    end;
    
    -- test 9: drop_scheduled_job success case
    begin
        util_pkg.drop_scheduled_job(
            p_job_name => v_job_name
        );
        select count(*) into v_count
        from user_scheduler_jobs
        where job_name = v_job_name;
        if v_count = 0 then
            dbms_output.put_line('test 9: drop_scheduled_job success - passed');
        else
            dbms_output.put_line('test 9: drop_scheduled_job success - failed');
        end if;
    exception
        when others then
            dbms_output.put_line('test 9: drop_scheduled_job success - error: ' || sqlerrm);
    end;
    
    -- test 10: drop_scheduled_job failure case (null job_name)
    begin
        util_pkg.drop_scheduled_job(
            p_job_name => null
        );
        dbms_output.put_line('test 10: drop_scheduled_job failure - failed (should have raised exception)');
    exception
        when others then
            if sqlcode = -20009 then
                dbms_output.put_line('test 10: drop_scheduled_job failure - passed');
            else
                dbms_output.put_line('test 10: drop_scheduled_job failure - error: ' || sqlerrm);
            end if;
    end;
    
    commit;
exception
    when others then
        v_error_code := sqlcode;
        v_error_message := sqlerrm;
        dbms_output.put_line('main test block error: ' || v_error_message);
        util_pkg.log_error(
            'util_pkg_test',
            v_error_code,
            v_error_message,
            dbms_utility.format_error_backtrace
        );
        rollback;
        raise;
end;