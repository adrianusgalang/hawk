# README

[![Coverage Status](https://opencov.bukalapak.io/badges/375/svg)](https://opencov.bukalapak.io/projects/375)
## Description
HAWK is a system that allows anyone on Bukalapak to do monitoring on their metrics of interest by registering a redash id on HAWK dashboard. HAWK would automatically calculate the threshold (upper and lower control limit) for the monitoring. The system would create an alert when a data point crosses the threshold. By using this system, we hope that the internal monitoring in Bukalapak would be done in a simple and scientific way.

## SLO and SLI
- Availability: 99%
- Response time: <10ms

## Links
-  [HAWKINS for HAWK dashboard repository](https://github.com/bukalapak/hawkins)

## Request Flows
![alt text](https://github.com/bukalapak/hawk/blob/prototype-10/pic/hawk.png)

## Endpoints
- [Hawk Endpoint](https://bukalapak.atlassian.net/wiki/spaces/DAS/pages/710213904/Hawk+Endpoint)

## Hawk Scoring
- [Hawk Scoring](https://bukalapak.atlassian.net/wiki/spaces/DAS/pages/709984594/Hawk+Scoring)

## Hawk System Design
- [Hawk System Design](https://bukalapak.atlassian.net/wiki/spaces/DAS/pages/714178703/Hawk+Design)

## Hawk Feature
- [Hawk Feature](https://bukalapak.atlassian.net/wiki/spaces/DAS/pages/713721002/Hawk+Feature)

## Hawk How to Use
- [Hawk How to Use](https://bukalapak.atlassian.net/wiki/spaces/DAS/pages/713590021/Hawk+How+to+Use)

## Dependencies
- Ruby 2.4.1
- mysql 5.7
- Redash (http://redash.bukalapak.io)

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

### Deployment

#### Gitlab Deployment (Preferred)

- Create release branch with prefix `deploy-` and push it
  ```
  date +deploy-%Y%m%d-%H%M%S
  git checkout -b deploy-20180306-150408
  git push origin deploy-20180306-150408
  ```

- Connect to Bukalapak VPN
- Go to https://gitlab.bukalapak.io/bukalapak/hawk/pipelines
- Wait until the 'build' stage has been passed
- Run deployment by clicking the 'Play' (the triangle) button on `Deploy Production` job

#### Gitlab Migration (Preferred)

- Create release branch with prefix `migrate-run-production-` and push it
  ```
  date +migrate-run-production-%Y%m%d-%H%M%S
  git checkout -b migrate-run-production-20180306-150408
  git push origin migrate-run-production-20180306-150408
  ```

- Connect to Bukalapak VPN
- Go to https://gitlab.bukalapak.io/bukalapak/hawk/pipelines
- Wait until the 'migrate' stage has been passed

## Database
- [Database Architecture](https://bukalapak.atlassian.net/wiki/spaces/DAS/pages/710181158/Hawk+Database)

## FAQ
- Can't start server because server already running => remove file server.pids from tmp/pids then Start the server
- More question [Data Access](https://bukalapak.atlassian.net/wiki/spaces/DAS/overview)

## Owner
- [Data Access](https://bukalapak.atlassian.net/wiki/spaces/DAS/overview)

## Contact and On-Call Information
- [Data Access](https://bukalapak.atlassian.net/wiki/spaces/DAS/overview)

## On-Call Runbooks
- [Data Access](https://bukalapak.atlassian.net/wiki/spaces/DAS/overview)
