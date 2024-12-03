#!/bin/bash

# Define Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Define data files
STUDENT_FILE="./students.txt"
COURSE_FILE="./courses.txt"
ASSIGNED_COURSES_FILE="./assigned_courses.txt"
ADMIN_FILE="./admin.txt"

# Ensure files exist and initialize with sample data if needed
initialize_files() {
    touch "$STUDENT_FILE" "$COURSE_FILE" "$ASSIGNED_COURSES_FILE"

    if [ ! -f "$ADMIN_FILE" ]; then
        echo "admin|admin123" > "$ADMIN_FILE"
    fi

    if [ ! -s "$COURSE_FILE" ]; then
        echo "Math 101|Fall|2024" >> "$COURSE_FILE"
        echo "History 101|Spring|2024" >> "$COURSE_FILE"
        echo "Science 101|Fall|2024" >> "$COURSE_FILE"
    fi
}

# Generate a unique student ID
generate_student_id() {
    local last_id=$(tail -n 1 "$STUDENT_FILE" | cut -d'|' -f1 | sed 's/S//')
    if [ -z "$last_id" ]; then
        echo "S001"
    else
        printf "S%03d" $((10#$last_id + 1))
    fi
}

# Admin login function
admin_login() {
    clear
    echo -e "\n${CYAN}           === Admin Login ===${RESET}\n"
    echo -e "${YELLOW}Enter Username:${RESET} "
    read username
    echo -e "${YELLOW}Enter Password:${RESET} "
    read -s password

    if grep -q "^$username|$password$" "$ADMIN_FILE"; then
        echo -e "\n${GREEN}Login successful!${RESET}"
        admin_menu
    else
        echo -e "\n${RED}Invalid credentials.${RESET}"
        echo -e "${MAGENTA}Press Enter to try again...${RESET}"
        read
    fi
}

# Admin menu function
admin_menu() {
    while true; do
        clear
        echo -e "\n${CYAN}           === Admin Panel ===${RESET}\n"
        echo -e "${WHITE}1. Manage Students${RESET}"
        echo -e "${WHITE}2. Manage Courses${RESET}"
        echo -e "${WHITE}3. Assign Courses to Students${RESET}"
        echo -e "${WHITE}4. Logout${RESET}"
        echo -e "${YELLOW}Enter your choice:${RESET} "
        read choice

        case $choice in
            1) manage_students ;;
            2) manage_courses ;;
            3) assign_courses ;;
            4) break ;;
            *) echo -e "${RED}Invalid choice!${RESET}" ;;
        esac
    done
}

# Manage students function
manage_students() {
    while true; do
        clear
        echo -e "\n${CYAN}           === Student Management ===${RESET}\n"
        echo -e "${WHITE}1. Add New Student${RESET}"
        echo -e "${WHITE}2. View All Students${RESET}"
        echo -e "${WHITE}3. Remove Student${RESET}"
        echo -e "${WHITE}4. Back to Admin Menu${RESET}"
        echo -e "${YELLOW}Enter your choice:${RESET} "
        read choice

        case $choice in
            1) 
                echo -e "${YELLOW}Enter Student Name:${RESET} "
                read student_name
                echo -e "${YELLOW}Enter Semester:${RESET} "
                read semester
                echo -e "${YELLOW}Enter Department:${RESET} "
                read department

                # Validate input
                if [[ -z "$student_name" || -z "$semester" || -z "$department" ]]; then
                    echo -e "${RED}All fields are required. Student not added.${RESET}"
                else
                    student_id=$(generate_student_id)
                    echo "$student_id|$student_name|$semester|$department" >> "$STUDENT_FILE"
                    echo -e "${GREEN}Student added successfully. Assigned ID: $student_id${RESET}"
                fi
                ;;

            2) 
                if [ -s "$STUDENT_FILE" ]; then
                    echo -e "\n${CYAN}=== List of Students ===${RESET}"
                    echo -e "${WHITE}ID       Name         Semester     Department${RESET}"
                    column -t -s '|' "$STUDENT_FILE"
                else
                    echo -e "${RED}No students available.${RESET}"
                fi
                ;;
            3) 
                echo -e "${YELLOW}Enter Student ID to Remove:${RESET} "
                read student_id
                if grep -q "^$student_id|" "$STUDENT_FILE"; then
                    grep -v "^$student_id|" "$STUDENT_FILE" > temp.txt && mv temp.txt "$STUDENT_FILE"
                    grep -v "^$student_id|" "$ASSIGNED_COURSES_FILE" > temp.txt && mv temp.txt "$ASSIGNED_COURSES_FILE"
                    echo -e "${GREEN}Student removed successfully.${RESET}"
                else
                    echo -e "${RED}Student ID not found.${RESET}"
                fi
                ;;
            4) break ;;
            *) echo -e "${RED}Invalid choice!${RESET}" ;;
        esac
        echo -e "${MAGENTA}Press Enter to continue...${RESET}"
        read
    done
}

# Manage courses function
manage_courses() {
    while true; do
        clear
        echo -e "\n${CYAN}           === Course Management ===${RESET}\n"
        echo -e "${WHITE}1. Add New Course${RESET}"
        echo -e "${WHITE}2. View All Courses${RESET}"
        echo -e "${WHITE}3. Delete Course${RESET}"
        echo -e "${WHITE}4. Back to Admin Menu${RESET}"
        echo -e "${YELLOW}Enter your choice:${RESET} "
        read choice

        case $choice in
            1) 
                echo -e "${YELLOW}Enter Course Name:${RESET} "
                read course_name
                echo -e "${YELLOW}Enter Semester (Fall/Spring):${RESET} "
                read semester
                echo -e "${YELLOW}Enter Year:${RESET} "
                read year

                # Validate input
                if [[ -z "$course_name" || -z "$semester" || -z "$year" ]]; then
                    echo -e "${RED}All fields are required. Course not added.${RESET}"
                else
                    if grep -q "^$course_name|" "$COURSE_FILE"; then
                        echo -e "${RED}Course already exists.${RESET}"
                    else
                        echo "$course_name|$semester|$year" >> "$COURSE_FILE"
                        echo -e "${GREEN}Course added successfully.${RESET}"
                    fi
                fi
                ;;
            2) 
                if [ -s "$COURSE_FILE" ]; then
                    echo -e "\n${CYAN}=== List of Courses ===${RESET}"
                    echo -e "${WHITE}Course Name     Semester     Year${RESET}"
                    column -t -s '|' "$COURSE_FILE"
                    echo -e "\n${CYAN}Courses offered in Fall:${RESET}"
                    grep "|Fall|" "$COURSE_FILE" | cut -d'|' -f1
                    echo -e "\n${CYAN}Courses offered in Spring:${RESET}"
                    grep "|Spring|" "$COURSE_FILE" | cut -d'|' -f1
                else
                    echo -e "${RED}No courses available.${RESET}"
                fi
                ;;
            3) 
                echo -e "${YELLOW}Enter Course Name to Delete:${RESET} "
                read course_name
                if grep -q "^$course_name|" "$COURSE_FILE"; then
                    grep -v "^$course_name|" "$COURSE_FILE" > temp.txt && mv temp.txt "$COURSE_FILE"
                    echo -e "${GREEN}Course deleted.${RESET}"
                else
                    echo -e "${RED}Course not found.${RESET}"
                fi
                ;;
            4) break ;;
            *) echo -e "${RED}Invalid choice!${RESET}" ;;
        esac
        echo -e "${MAGENTA}Press Enter to continue...${RESET}"
        read
    done
}

# Assign courses to students
assign_courses() {
    clear
    echo -e "\n${CYAN}           === Assign Courses to Students ===${RESET}\n"
    echo -e "${YELLOW}Enter Student ID:${RESET} "
    read student_id
    if grep -q "^$student_id|" "$STUDENT_FILE"; then
        echo -e "\n${CYAN}=== Available Courses ===${RESET}"
        column -t -s '|' "$COURSE_FILE"
        echo -e "${YELLOW}Enter Course Name to Assign:${RESET} "
        read course_name
        if grep -q "^$course_name|" "$COURSE_FILE"; then
            echo "$student_id|$course_name" >> "$ASSIGNED_COURSES_FILE"
            echo -e "${GREEN}Course assigned to student successfully.${RESET}"
        else
            echo -e "${RED}Course not found.${RESET}"
        fi
    else
        echo -e "${RED}Student ID not found.${RESET}"
    fi
    echo -e "${MAGENTA}Press Enter to continue...${RESET}"
    read
}


# Remove a student
remove_student() {
    clear
    echo -e "\n${CYAN}           === Remove Student ===${RESET}\n"
    echo -e "${YELLOW}Enter Student ID to Remove:${RESET} "
    read student_id
    if grep -q "^$student_id|" "$STUDENT_FILE"; then
        grep -v "^$student_id|" "$STUDENT_FILE" > temp.txt && mv temp.txt "$STUDENT_FILE"
        grep -v "^$student_id|" "$ASSIGNED_COURSES_FILE" > temp.txt && mv temp.txt "$ASSIGNED_COURSES_FILE"
        echo -e "${GREEN}Student removed successfully.${RESET}"
    else
        echo -e "${RED}Student ID not found.${RESET}"
    fi
    echo -e "${MAGENTA}Press Enter to continue...${RESET}"
    read
}

# Student menu function
student_menu() {
    while true; do
        clear
        echo -e "\n${CYAN}           === Student Menu ===${RESET}\n"
        echo -e "${WHITE}1. View Assigned Courses${RESET}"
        echo -e "${WHITE}2. Logout${RESET}"
        echo -e "${YELLOW}Enter your choice:${RESET} "
        read choice

        case $choice in
            1)
                student_id=$1
                echo -e "\n${CYAN}=== Assigned Courses ===${RESET}"
                assigned_courses=$(grep "^$student_id|" "$ASSIGNED_COURSES_FILE" | cut -d'|' -f2)
                if [ -z "$assigned_courses" ]; then
                    echo -e "${RED}No courses assigned.${RESET}"
                else
                    echo -e "$assigned_courses"
                fi
                ;;
            2) 
                echo -e "${MAGENTA}Logging out...${RESET}"
                break ;;
            *)
                echo -e "${RED}Invalid choice!${RESET}" ;;
        esac
        echo -e "${MAGENTA}Press Enter to continue...${RESET}"
        read
    done
}

# Student login function
student_login() {
    clear
    echo -e "\n${CYAN}           === Student Login ===${RESET}\n"
    echo -e "${YELLOW}Enter Your Name:${RESET} "
    read student_name

    student_record=$(grep "|$student_name|" "$STUDENT_FILE")
    if [ -n "$student_record" ]; then
        student_id=$(echo "$student_record" | cut -d'|' -f1)
        echo -e "\n${GREEN}Welcome, $student_name! Your ID is: $student_id${RESET}"
        student_menu "$student_id"
    else
        echo -e "${RED}No record found for $student_name.${RESET}"
        echo -e "${MAGENTA}Press Enter to try again...${RESET}"
        read
    fi
}

# Main menu function
main_menu() {
    while true; do
        clear
        echo -e "\n${BLUE}*******************************************${RESET}"
        echo -e "${CYAN}           COURSE MANAGEMENT SYSTEM         ${RESET}"
        echo -e "${BLUE}*******************************************${RESET}\n"
        echo -e "${WHITE}1. Admin Login${RESET}"
        echo -e "${WHITE}2. Student Login${RESET}"
        echo -e "${WHITE}3. Exit${RESET}"
        echo -e "${YELLOW}Enter your choice:${RESET} "
        read choice

        case $choice in
            1) admin_login ;;
            2) student_login ;;
            3) exit 0 ;;
            *) echo -e "${RED}Invalid choice!${RESET}" ;;
        esac
    done
}

# Initialize files and start
initialize_files
main_menu
