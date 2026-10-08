output "jenkins_public_ip" {
  description = "IP publica del servidor Jenkins"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "URL de Jenkins"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "instance_id" {
  description = "Identificador de la instancia EC2"
  value       = aws_instance.jenkins.id
}