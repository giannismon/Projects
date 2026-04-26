# Trigger Pipeline from VM

A cost-free alternative to Azure Functions and Logic Apps for triggering Azure DevOps pipelines. Instead of paying for managed triggers, this solution runs on an existing VM using only bash and cron — eliminating recurring costs while achieving the same result.

Monitors a URL every minute and automatically triggers an Azure DevOps pipeline to restart a service when it detects 25 consecutive failures. Includes a 2-hour cooldown to prevent repeated triggers.

## Motivation

Azure Functions and Logic Apps charge per execution when used as pipeline triggers. This script replicates that functionality at zero additional cost by leveraging a VM that is already running in the infrastructure.

## How It Works

1. `trigger.sh` runs every minute via cron
2. It checks the target URL's HTTP status code
3. Logs `1` (healthy) or `0` (unhealthy) to `url_status.log`
4. If the last 25 checks are all `0` **and** the cooldown has passed, it calls `pipeline.sh`
5. `pipeline.sh` triggers the Azure DevOps pipeline via the REST API
6. The cooldown timer resets and the log is cleared

## Setup

### 1. Configure `pipeline.sh`
```bash
AZDO_PAT="your_personal_access_token"
ORG="your_organization"
PROJECT="your_project_name"
PIPELINE_ID="your_pipeline_id"
BRANCH="main"
```

### 2. Configure `trigger.sh`
```bash
URL="https://your-website.com"
```

### 3. Add to crontab
```bash
crontab -e
* * * * * /path/to/trigger.sh
```

## Requirements
- `curl` installed
- Azure DevOps PAT with **Build (Read & execute)** permission
- Linux/macOS with cron
