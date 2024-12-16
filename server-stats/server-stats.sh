#!/bin/bash

# Function to display total CPU usage
display_cpu_usage() {
    echo -e "\033[1;34m--- CPU Usage ---\033[0m"
    if command -v mpstat &> /dev/null; then
        mpstat | grep -A 5 "%idle" | awk 'NR==5 {print "\033[1;32mCPU Usage:\033[0m " 100-$NF"%"}'
    else
        # Fallback if mpstat is not available
        awk -v OFMT="%.2f" '/^cpu / {usage=($2+$4)*100/($2+$4+$5); print "\033[1;32mCPU Usage:\033[0m " usage "%"}' /proc/stat
    fi
}

# Function to display memory usage
display_memory_usage() {
    echo -e "\033[1;34m--- Memory Usage ---\033[0m"
    free -m | awk 'NR==2{printf "\033[1;32mUsed:\033[0m %sMB, \033[1;32mFree:\033[0m %sMB, \033[1;32mUsage:\033[0m %.2f%%\n", $3,$4,$3*100/($3+$4)}'
}

# Function to display disk usage
display_disk_usage() {
    echo -e "\033[1;34m--- Disk Usage ---\033[0m"
    df -h --total | awk '/total/{printf "\033[1;32mUsed:\033[0m %s, \033[1;32mFree:\033[0m %s, \033[1;32mUsage:\033[0m %s\n", $3, $4, $5}'
}

# Function to display top 5 processes by CPU usage
display_top_processes_cpu() {
    echo -e "\033[1;34m--- Top 5 Processes by CPU Usage ---\033[0m"
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | awk 'NR==1 {print "\033[1;32m" $0 "\033[0m"} NR>1 {print $0}'
}

# Function to display top 5 processes by memory usage
display_top_processes_memory() {
    echo -e "\033[1;34m--- Top 5 Processes by Memory Usage ---\033[0m"
    ps -eo pid,comm,%mem --sort=-%mem | head -n 6 | awk 'NR==1 {print "\033[1;32m" $0 "\033[0m"} NR>1 {print $0}'
}

# Function to display additional stats (Stretch Goal)
display_additional_stats() {
    echo -e "\033[1;34m--- Additional Stats ---\033[0m"
    echo -e "\033[1;32mOS Version:\033[0m $(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2)"
    echo -e "\033[1;32mUptime:\033[0m $(uptime -p)"
    echo -e "\033[1;32mLoad Average:\033[0m $(uptime | awk -F'load average:' '{print $2}')"
    echo -e "\033[1;32mLogged-in Users:\033[0m"
    who | awk '{print "\033[1;32m" $0 "\033[0m"}'

    echo -e "\033[1;32mFailed Login Attempts:\033[0m $(journalctl _COMM=sshd | grep "Failed password" | wc -l)"
}

# Main script execution
show_additional_stats=false
clear
while true; do
    echo -e "\033[1;35mServer Performance Stats\033[0m"
    echo -e "\033[1;35m========================\033[0m"

    # Call functions to display stats
    display_cpu_usage
    display_memory_usage
    display_disk_usage
    display_top_processes_cpu
    display_top_processes_memory
    display_additional_stats

    echo ""
    echo -e "\033[1;33mPress 'q' to quit.\033[0m"
    sleep 1
    if read -t 0.1 -n 1 choice; then
        if [[ $choice == "q" || $choice == "Q" ]]; then
            break
        fi
    fi
    clear
done
