source common.sh
mysql_pass=$1
if [ -z "${mysql_pass}" ]; then          # -z will check if the variable is empty. if it is empty returns 0 or else returns 1
    echo "Enter mysql password"
    exit 1
fi
component=shipping
schema_type="mysql"
print_head "Install Maven"
yum install maven -y &>>${log_file}
status_check $?

ROBOSHOP_APP_SETUP

print_head "Download Dependencies & Package"
mvn clean package &>>${log_file}
mv target/${component}-1.0.jar ${component}.jar &>>${log_file}
status_check $?
SCHEMA_SETUP
SYSTEMD_FUNC