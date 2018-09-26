# README

## Description
HAWK is a system that allows anyone on Bukalapak to do monitoring on their metrics of interest by registering a redash id on HAWK dashboard. HAWK would automatically calculate the threshold (upper and lower control limit) for the monitoring. The system would create an alert when a data point crosses the threshold. By using this system, we hope that the internal monitoring in Bukalapak would be done in a simple and scientific way.

## SLO and SLI
- Availability: 99%
- Response time: <10ms

## Request Flows
![alt text](https://github.com/bukalapak/hawk/blob/prototype-10/pic/hawk.png)

## Endpoints
- [GET] /dashboard/summary

- [POST] /metric/update_all
- [POST] /metric/create
- [GET] /metric/manage
- [GET] /metric/new

- [GET] /healthz

- [GET] /alert
- [POST] /alert/confirmuser

- [GET] /date_exclude
- [POST] /date_exclude/removedateexclude


## Dependencies
- Ruby 2.5.1
- mysql 5.7
- Redash (http://redash.bukalapak.io)

## Architecture Diagram
HAWK use Statistical Process Control (SPC) to this monitoring system. SPC is commonly used in industry to determine whether a process is under control or not.  

HAWK take the ratio of a value to be monitored with respect to the corresponding value at the previous 28 days. HAWK notice there is a seasonal pattern on most of Bukalapak metrics and HAWK take into account this monthly cycle to our monitoring system. The ratio R of the monitored-value Y for a given time t (as an example here, t is in day) is defined as,

![alt text](https://github.com/bukalapak/hawk/blob/prototype_9/pic/img1.png)

The Rt is then transformed by sigmoid function as such the values fall between 0 and 1. The monitoring is then followed proportional control chart

![alt text](https://github.com/bukalapak/hawk/blob/prototype_9/pic/img2.png)

The upper (UCL) and lower (LCL) control limit is calculated as follows,

![alt text](https://github.com/bukalapak/hawk/blob/prototype_9/pic/img3.png)

where N is the sample size and

![alt text](https://github.com/bukalapak/hawk/blob/prototype_9/pic/img4.png)

To calculate the control limits, a minimum of 25 data points is needed

An alert will be sent to users when R't is greater than UCL or R't is less than the LCL. Hereafter, such data point is called as an outlier. The treatment to the outlier depends on the type of outlier, i.e. known and unknown outlier. The unknown outlier indicates there is an intrusion to the data and a further investigation is worthy to be initiated. Montgomery suggested to exclude the known outliers for the calculation of LCL and UC, as it is not the usual process that we would like to detect. We, however, replace the outlier values by the mean of data, as we need this data point to determine the control limits for the next following months.

HAWK would send an alert when there is an outlier detected, i.e. a point that crosses either lower or upper control limit. Further, HAWK would ask the user whether the outlier is know or not. In the case of known outlier, HAWK would shrink the R't value toward the mean and re-calculate the data point Yt based on the updated value of R't. The iteration process is visualized as follows.

![alt text](https://github.com/bukalapak/hawk/blob/prototype_9/pic/img5.png)

## Links
-  [HAWKINS for HAWK dashboard repository](https://github.com/bukalapak/hawkins)

## Setup

### Start the server

```
[sudo] rails s
```

### If you adding new dependencies, rebuild the image
```
[sudo] bundle install
[sudo] rails s
```

## Database

### database migration
```
rake db:migrate
```

### database architecture
- Database list
```
+--------------------+
| Database           |
+--------------------+
| hawk_dev           |
| hawk_prod          |
| hawk_test          |
+--------------------+
```
- Table list
```
+----------------------+
| Tables_in_hawk_dev   |
+----------------------+
| alerts               |
| date_excs            |
| metrics              |
+----------------------+
```
- Alerts Table
```
+----------------+--------------+------+-----+---------+----------------+
| Field          | Type         | Null | Key | Default | Extra          |
+----------------+--------------+------+-----+---------+----------------+
| id             | int(11)      | NO   | PRI | NULL    | auto_increment |
| created_at     | datetime     | NO   |     | NULL    |                |
| updated_at     | datetime     | NO   |     | NULL    |                |
| value          | float        | YES  |     | NULL    |                |
| is_upper       | tinyint(1)   | YES  |     | NULL    |                |
| metric_id      | int(11)      | YES  |     | NULL    |                |
| exclude_status | tinyint(4)   | YES  |     | NULL    |                |
| date           | varchar(255) | YES  |     | NULL    |                |
+----------------+--------------+------+-----+---------+----------------+
```
- Metrics Table
```
+-----------------+--------------+------+-----+---------+----------------+
| Field           | Type         | Null | Key | Default | Extra          |
+-----------------+--------------+------+-----+---------+----------------+
| id              | int(11)      | NO   | PRI | NULL    | auto_increment |
| created_at      | datetime     | NO   |     | NULL    |                |
| updated_at      | datetime     | NO   |     | NULL    |                |
| redash_id       | int(11)      | YES  |     | NULL    |                |
| redash_title    | varchar(255) | YES  |     | NULL    |                |
| time_column     | varchar(255) | YES  |     | NULL    |                |
| value_column    | varchar(255) | YES  |     | NULL    |                |
| time_unit       | tinyint(4)   | YES  |     | NULL    |                |
| value_type      | tinyint(4)   | YES  |     | NULL    |                |
| email           | varchar(255) | YES  |     | NULL    |                |
| upper_threshold | float        | YES  |     | NULL    |                |
| lower_threshold | float        | YES  |     | NULL    |                |
| result_id       | varchar(255) | YES  |     | NULL    |                |
| telegram_chanel | varchar(255) | YES  |     | NULL    |                |
+-----------------+--------------+------+-----+---------+----------------+
```
- Date Exclude
```
+------------+--------------+------+-----+---------+----------------+
| Field      | Type         | Null | Key | Default | Extra          |
+------------+--------------+------+-----+---------+----------------+
| id         | int(11)      | NO   | PRI | NULL    | auto_increment |
| created_at | datetime     | NO   |     | NULL    |                |
| updated_at | datetime     | NO   |     | NULL    |                |
| date       | varchar(255) | YES  |     | NULL    |                |
| value      | float        | YES  |     | NULL    |                |
| ratio      | float        | YES  |     | NULL    |                |
| time_unit  | tinyint(4)   | YES  |     | NULL    |                |
| redash_id  | varchar(255) | YES  |     | NULL    |                |
| note       | text         | YES  |     | NULL    |                |
+------------+--------------+------+-----+---------+----------------+
```
## FAQ
- Can't start server because server already running => remove file server.pids from tmp/pids then Start the server
- More question https://t.me/joinchat/H0CS3g8dtpQhPEzyHR--tw

## Owner
- HAWK

## Contact and On-Call Information
- https://t.me/joinchat/H0CS3g8dtpQhPEzyHR--tw

## On-Call Runbooks
- https://t.me/joinchat/H0CS3g8dtpQhPEzyHR--tw
