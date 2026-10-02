output "lab_id" {
  description = "ID del lab en CML."
  value       = cml2_lifecycle.lab.id
}

output "booted" {
  description = "true cuando todos los nodos terminaron de arrancar."
  value       = cml2_lifecycle.lab.booted
}

output "nodes" {
  description = "Nodos del lab y su estado."
  value       = { for id, node in cml2_lifecycle.lab.nodes : node.label => node.state }
}
