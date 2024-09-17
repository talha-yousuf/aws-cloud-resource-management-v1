### Task 1: Infrastructure Setup

1. Create an IAM user with programmatic access/necessary permissions to manage EC2, RDS, ElastiCache, and IAM resources. ✅
1. Create a VPC with two public subnets and two private subnets. ✅
1. Launch an Auto Scaling group with two EC2 instances in the public subnets. ✅
1. Launch an Auto Scaling group with two EC2 instances in the private subnets. ⛔
1. Create a RDS MySQL database instance in a multi-AZ configuration. ✅
1. Create an ElastiCache Redis cluster with two nodes. ✅

### Task 2: Application Deployment

1. Bundle and upload a sample node.js app to s3. ✅
1. Deploy a the app on the EC2 instances using autoscaling group userData script and code-deploy agent. ✅
1. Deploy a the app on the EC2 instances using AWS Code Deploy. ⛔
1. Configure the application to bring in env variables from the stack for RDS and Redis. ✅
1. Save secret in AWS Secrets Manager. Pull secrets in template and the app form there. ⛔
1. Connect to the RDS database and ElastiCache cluster in the app. ✅
1. Implement basic load balancing using EC2 instances. ✅

### Task 3: Performance Testing and Optimization

1. Simulate increased traffic using a load testing tool (e.g., Apache JMeter).
1. Monitor the performance of the EC2 instances, RDS database, and ElastiCache cluster.
1. Identify performance bottlenecks and implement optimizations. ⛔

### Task 4: Security Best Practices

1. Implement security best practices for EC2, RDS, and ElastiCache.
1. Configure IAM roles and policies to restrict access to resources.
1. Enable AWS security features (e.g., AWS WAF, Shield).
1. Create Ruleset to restrict traffic from specific country.
