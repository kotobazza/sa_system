#!/bin/bash

# Восстановление базы данных
psql -U postgres -f /dump/dump.sql 
