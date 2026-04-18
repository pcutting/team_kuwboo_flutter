// PM2 config for the kuwboo-slack-runner.
// Deploy:
//   pm2 start ecosystem.config.cjs
//   pm2 save
//   pm2 startup  # once per host
module.exports = {
  apps: [
    {
      name: 'kuwboo-slack-runner',
      script: 'node_modules/.bin/tsx',
      args: 'src/runner.ts',
      cwd: '/home/ubuntu/kuwboo-slack-runner',
      env: {
        NODE_ENV: 'production',
        AWS_REGION: 'eu-west-2',
        RUNNER_PORT: '4100',
        AGENT_RUNS_DIR: '/home/ubuntu/agent-runs',
        // Secrets are pulled from AWS Secrets Manager at boot — nothing
        // sensitive lives in this file.
      },
      max_restarts: 5,
      min_uptime: '30s',
      max_memory_restart: '1G',
      error_file: '/home/ubuntu/logs/kuwboo-slack-runner.err.log',
      out_file: '/home/ubuntu/logs/kuwboo-slack-runner.out.log',
      merge_logs: true,
      time: true,
    },
  ],
};
