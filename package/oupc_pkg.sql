create or replace package util_pkg as
    procedure log_audit(
        p_table_name in varchar2,
        p_operation in varchar2,
        p_record_id in number,
        p_details in varchar2
    );
    
    procedure log_error(
        p_module_name in varchar2,
        p_error_code in number,
        p_error_message in varchar2,
        p_stack_trace in varchar2
    );
    
    procedure send_email_alert(
        p_recipient in varchar2,
        p_subject in varchar2,
        p_message in varchar2
    );
    
    procedure create_scheduled_job(
        p_job_name in varchar2,
        p_job_action in varchar2,
        p_start_date in timestamp,
        p_repeat_interval in varchar2
    );
    
    procedure drop_scheduled_job(
        p_job_name in varchar2
    );
end util_pkg;
