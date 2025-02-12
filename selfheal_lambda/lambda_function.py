import boto3
import os

ecs = boto3.client('ecs')

def lambda_handler(event, context):
    cluster_name = 'automation'
    service_name = 'automation'

    try:
        tasks_response = ecs.list_tasks(
            cluster=cluster_name,
            serviceName=service_name,
            desiredStatus='RUNNING'
        )

        task_arns = tasks_response.get('taskArns', [])

        if not task_arns:
            print("No running tasks found")
            return {"message": "No tasks to restart"}

        task_arn = task_arns[0]
        ecs.stop_task(
            cluster=cluster_name,
            task=task_arn,
            reason="Restart requested by Lambda"
        )

        print(f"Stopped task: {task_arn}")

        return {"message": "Task restarted successfully", "task_arn": task_arn}
    
    except Exception as e:
        print(f"Error restarting ECS task: {e}")
        return {"error": str(e)}