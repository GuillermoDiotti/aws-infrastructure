output "budget_name" {
  description = "Budget name"
  value       = aws_budgets_budget.monthly_cost.name
}

output "budget_id" {
  description = "Budget ID"
  value       = aws_budgets_budget.monthly_cost.id
}