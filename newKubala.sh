#!/usr/bin/bash
howManyProjects=$(./newCountProjects.sh | wc -l)
echo "Number of projects: " ${howManyProjects}

if [ "$howManyProjects" -eq 0 ]; then
    echo "There are no projects, i'll create one for you."
    echo "creating project"
elif [ "$howManyProjects" -eq 1 ]; then
    echo "There is one project, let's go forward."
    echo "next steps"
else
    echo "There is more than one project, don't know what to do, exiting."
fi

    
#gcloud compute instances list
