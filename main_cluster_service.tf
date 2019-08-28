resource "aws_ecs_task_definition" "services_task_def" {
  family                = "ips-services-td-tf"
  memory                = "1024"
  container_definitions = <<EOF
[
  {
  "name": "ips-services",
  "image": "014669633018.dkr.ecr.eu-west-2.amazonaws.com/ips-services:2",
  "cpu": 0,
  "memory": null,
  "memoryReservation": null,
  "essential": true,
  "environment": [
    {
      "name": "DB_NAME",
      "value": "ips"
    },
    {
redacted  # Replace, using a regex
      "value": "qsB9m9IwKG1CaC5Uu2qqmjUMaHGLXA"
    },
    {
      "name": "DB_SERVER",
      "value": "ips-db.cyjaepzpx1tk.eu-west-2.rds.amazonaws.com"
    },
    {
      "name": "DB_USER_NAME",
      "value": "admin"
    }
  ],
  "portMappings": [
    {
      "hostPort": 5000,
      "protocol": "tcp",
      "containerPort": 5000
    }
  ]
}
]
EOF


  volume {
    name      = "service-storage-tf"
    host_path = "/ecs/service-storage"
  }
}