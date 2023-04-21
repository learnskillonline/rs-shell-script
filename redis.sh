source common.sh
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
dnf module enable redis:remi-6.2 -y
yum install redis -y
sed -i "s/127.0.0.1/0.0.0.0/" /etc/redis.conf /etc/redis/redis.conf
SYSTEMD_FUNC