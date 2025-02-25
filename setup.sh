#!/bin/bash

# Create a shortcut for running SQL queries
alias sqlq='sqlcmd -S localhost -U sa -P P@ssw0rd -d Northwind -Q'

# Save the alias permanently
echo "alias sqlq='sqlcmd -S localhost -U sa -P P@ssw0rd -d Northwind -Q'" >> ~/.bashrc