-- creating audit log table
create table audit_log (
    log_id number primary key,
    table_name varchar2(30),
    operation varchar2(10),
    record_id number,
    change_date timestamp default current_timestamp,
    changed_by varchar2(30),
    details varchar2(4000)
);

-- creating error log table
create table error_log (
    error_id number primary key,
    error_code number,
    error_message varchar2(4000),
    stack_trace varchar2(4000),
    log_date timestamp default current_timestamp,
    module_name varchar2(100)
);