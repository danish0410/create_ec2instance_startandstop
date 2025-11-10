import boto3
import sys

region = "ap-south-1"
instances = ['i-0123456789abcdef0']  # Replace with your instance ID
ec2 = boto3.client('ec2', region_name=region)

def start_instance():
    print("Starting EC2 instance...")
    ec2.start_instances(InstanceIds=instances)
    print("✅ Instance started successfully.")

def stop_instance():
    print("Stopping EC2 instance...")
    ec2.stop_instances(InstanceIds=instances)
    print("✅ Instance stopped successfully.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python manage_ec2.py [start|stop]")
        sys.exit(1)
    action = sys.argv[1].lower()
    if action == "start":
        start_instance()
    elif action == "stop":
        stop_instance()
    else:
        print("Invalid action. Use 'start' or 'stop'.")
