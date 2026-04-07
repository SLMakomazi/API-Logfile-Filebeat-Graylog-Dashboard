# Graylog Beats Input Setup Guide

## Steps to Configure Beats Input in Graylog

1. **Access Graylog Web Interface**
   - Open browser: http://localhost:9000
   - Login with: admin / admin

2. **Navigate to Inputs**
   - Go to `System` > `Inputs`
   - Select `Beats` from the dropdown menu
   - Click `Launch new input`

3. **Configure Beats Input**
   - **Title**: `Spring Boot API Logs`
   - **Port**: `5044` (default)
   - **Bind address**: `0.0.0.0` (listen on all interfaces)
   - **TLS**: `disabled` (for development)
   - **Number of workers**: `1`
   - **Batch size**: `125`
   - **Max batch size**: `2048`

4. **Save and Start**
   - Click `Save` to create the input
   - Click `Start input` to begin receiving logs

5. **Verify Input Status**
   - The input should show as `running` in green
   - Check the `Show received messages` section for incoming logs

## Expected Log Fields from Filebeat

When Filebeat sends logs, you should see these fields:
- `@timestamp`: Log timestamp
- `logtype`: `springboot-api`
- `service`: `item-crud-api`
- `host.hostname`: Hostname where the log originated
- `message`: The actual log message
- `agent.name`: filebeat
- `ecs.version`: ECS schema version

## Troubleshooting

- **No logs received**: Check Filebeat configuration and connectivity
- **Input not starting**: Verify port 5044 is not in use
- **Connection refused**: Ensure Graylog is running and input is started
- **Firewall issues**: Check if port 5044 is blocked

## Dashboard Creation

After logs start flowing:
1. Go to `Dashboards` > `Create dashboard`
2. Add widgets for:
   - API request count over time
   - Response time distribution
   - HTTP status codes
   - Most accessed endpoints
   - Error rate monitoring
