create or replace package body util_pkg as
    procedure log_audit(
        p_table_name in varchar2,
        p_operation in varchar2,
        p_record_id in number,
        p_details in varchar2
    ) is
        v_log_id number;
    begin
        -- validate inputs
        if p_table_name is null or p_operation is null then
            raise_application_error(-20001, 'table name and operation are required');
        end if;
        
        -- generate log id
        select audit_log_seq.nextval into v_log_id from dual;
        
        -- insert audit log
        insert into audit_log (
            log_id,
            table_name,
            operation,
            record_id,
            changed_by,
            details
        ) values (
            v_log_id,
            p_table_name,
            p_operation,
            p_record_id,
            user,
            p_details
        );
        
        commit;
        
    exception
        when others then
            rollback;
            raise_application_error(-20002, 'error logging audit: ' || sqlerrm);
    end log_audit;
    
    procedure log_error(
        p_module_name in varchar2,
        p_error_code in number,
        p_error_message in varchar2,
        p_stack_trace in varchar2
    ) is
        v_error_id number;
    begin
        -- validate inputs
        if p_module_name is null then
            raise_application_error(-20003, 'module name is required');
        end if;
        
        -- generate error id
        select error_log_seq.nextval into v_error_id from dual;
        
        -- insert error log
        insert into error_log (
            error_id,
            error_code,
            error_message,
            stack_trace,
            module_name
        ) values (
            v_error_id,
            p_error_code,
            p_error_message,
            p_stack_trace,
            p_module_name
        );
        
        commit;
        
    exception
        when others then
            rollback;
            raise_application_error(-20004, 'error logging error: ' || sqlerrm);
    end log_error;
    
    procedure send_email_alert(
        p_recipient in varchar2,
        p_subject in varchar2,
        p_message in varchar2
    ) is
    begin
        -- validate inputs
        if p_recipient is null or p_subject is null or p_message is null then
            raise_application_error(-20005, 'recipient, subject, and message are required');
        end if;
        
        -- send email using utl_mail
        utl_mail.send(
            sender => 'noreply@yourdomain.com',
            recipients => p_recipient,
            subject => p_subject,
            message => p_message,
            mime_type => 'text/plain; charset=us-ascii'
        );
        
        commit;
        
    exception
        when others then
            rollback;
            log_error(
                'util_pkg.send_email_alert',
                sqlcode,
                sqlerrm,
                dbms_utility.format_error_backtrace
            );
            raise_application_error(-20006, 'error sending email: ' || sqlerrm);
    end send_email_alert;
    
    procedure create_scheduled_job(
        p_job_name in varchar2,
        p_job_action in varchar2,
        p_start_date in timestamp,
        p_repeat_interval in varchar2
    ) is
    begin
        -- validate inputs
        if p_job_name is null or p_job_action is null then
            raise_application_error(-20007, 'job name and action are required');
        end if;
        
        -- create job using dbms_scheduler
        dbms_scheduler.create_job(
            job_name => p_job_name,
            job_type => 'plsql_block',
            job_action => p_job_action,
            start_date => p_start_date,
            repeat_interval => p_repeat_interval,
            enabled => true,
            auto_drop => false
        );
        
        commit;
        
    exception
        when others then
            rollback;
            log_error(
                'util_pkg.create_scheduled_job',
                sqlcode,
                sqlerrm,
                dbms_utility.format_error_backtrace
            );
            raise_application_error(-20008, 'error creating job: ' || sqlerrm);
    end create_scheduled_job;
    
    procedure drop_scheduled_job(
        p_job_name in varchar2
    ) is
    begin
        -- validate input
        if p_job_name is null then
            raise_application_error(-20009, 'job name is required');
        end if;
        
        -- drop job
        dbms_scheduler.drop_job(
            job_name => p_job_name
        );
        
        commit;
        
    exception
        when others then
            rollback;
            log_error(
                'util_pkg.drop_scheduled_job',
                sqlcode,
                sqlerrm,
                dbms_utility.format_error_backtrace
            );
            raise_application_error(-20010, 'error dropping job: ' || sqlerrm);
    end drop_scheduled_job;
end util_pkg;
