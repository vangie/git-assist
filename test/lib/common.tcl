# Common test utilities and configuration

# Load required packages
package require Expect

# Set timeout for all tests
set timeout 20

# Function to setup paths relative to the test directory
proc setup_paths {repo_path} {
    set repo_name [file tail $repo_path]
    set script_dir [file dirname [file normalize [info script]]]
    set lib_dir [file dirname $script_dir]
    set test_dir [file dirname $lib_dir]
    set root_dir [file dirname $test_dir]
    
    # Determine which command to use based on repository name prefix
    if {[string match "gen_*" $repo_name]} {
        set cmd "git-gen"
    } elseif {[string match "up_*" $repo_name]} {
        set cmd "git-up"
    } else {
        puts "Error: Invalid repository name format: $repo_name"
        exit 1
    }
    
    # Use absolute path to the command in project root's bin directory
    set bin_path [file join $root_dir "bin" $cmd]
    
    # Verify the command exists
    if {![file exists $bin_path]} {
        puts "Error: Command not found: $bin_path"
        puts "Current directory: [pwd]"
        puts "Script directory: $script_dir"
        puts "Lib directory: $lib_dir"
        puts "Test directory: $test_dir"
        puts "Root directory: $root_dir"
        puts "Expected command path: $bin_path"
        exit 1
    }
    
    # Return values as a dict
    return [dict create \
        repo_path $repo_path \
        repo_name $repo_name \
        test_dir $test_dir \
        root_dir $root_dir \
        bin_path $bin_path \
    ]
}

# Function to print test status
proc test_pass {message} {
    puts "  ✓ $message"
}

proc test_fail {message} {
    puts "  ✗ $message"
    exit 1
}

# Function to format a test section header
proc section {title} {
    puts "\n$title..."
} 