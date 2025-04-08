# Test functions for git-gen

# Load required packages
package require Expect

# Debug options controlled by environment variables
if { [info exists ::env(DEBUG)] && $::env(DEBUG) eq "true" } {
    exp_internal 1
    log_user 1
} else {
    exp_internal 0
    log_user 1
}

# Function to test help output
proc test_help {bin_path} {
    spawn $bin_path --help
    expect {
        -re {Usage:.*} {
            test_pass "Help message displayed correctly"
            return
        }
        timeout {
            test_fail "Timeout waiting for help message"
        }
    }
}

# Function to test message-only mode
proc test_msg_only {bin_path} {
    spawn $bin_path --msg-only
    expect {
        -re {.+} {
            test_pass "Message generated successfully"
            return
        }
        timeout {
            test_fail "Timeout waiting for message"
        }
    }
}

# Function to test normal commit with staged changes
proc test_staged_commit {bin_path} {
    spawn $bin_path
    expect {
        -exact "Changes to be committed:" {
            test_pass "Listed staged files"
            exp_continue
        }
        -exact "Commit the changes above and generate message? (Y/n): " {
            exp_send "y\r"
            test_pass "Confirmed changes"
            exp_continue
        }
        -exact "Generating commit message..." {
            exp_continue
        }
        -re "\\r+Generated commit message:" {
            test_pass "Generated commit message"
            exp_continue
        }
        -exact "Use this message? (Y/n/\[e\]dit/\[r\]egenerate): " {
            exp_send "y\r"
            test_pass "Accepted message"
            exp_continue
        }
        -re "Changes committed successfully!\\r?\\n?$" {
            test_pass "Commit completed successfully"
            return
        }
        timeout {
            test_fail "Timeout waiting for prompt"
        }
        eof {
            test_fail "Unexpected end of output"
        }
    }
}

# Function to test commit after staging changes
proc test_unstaged_commit {bin_path} {
    spawn $bin_path
    expect {
        -exact "No staged changes found. Would you like to stage all changes? (y/N) " {
            exp_send "y\r"
            test_pass "Staging all changes"
            exp_continue
        }
        -exact "Changes to be committed:" {
            test_pass "Listed staged files"
            exp_continue
        }
        -exact "Commit the changes above and generate message? (Y/n): " {
            exp_send "y\r"
            test_pass "Confirmed changes"
            exp_continue
        }
        -exact "Generating commit message..." {
            exp_continue
        }
        -re "\\r+Generated commit message:" {
            test_pass "Generated commit message"
            exp_continue
        }
        -exact "Use this message? (Y/n/\[e\]dit/\[r\]egenerate): " {
            exp_send "y\r"
            test_pass "Accepted message"
            exp_continue
        }
        -re "Changes committed successfully!\\r?\\n?$" {
            test_pass "Commit completed successfully"
            return
        }
        timeout {
            test_fail "Timeout waiting for prompt"
        }
        eof {
            test_fail "Unexpected end of output"
        }
    }
}

# Function to test empty/clean repo
proc test_clean_repo {bin_path} {
    spawn $bin_path
    expect {
        -re {No changes to commit} {
            test_pass "Correctly reported no changes"
            return
        }
        timeout {
            test_fail "Timeout waiting for response"
        }
    }
}

# Function to test amend mode
proc test_amend {bin_path} {
    spawn $bin_path --amend
    expect {
        -exact "Generating improved commit message..." {
            exp_continue
        }
        -re "\\r*Improved commit message:" {
            test_pass "Generated improved message"
            exp_continue
        }
        -exact "Use this message? (Y/n/\[e\]dit): " {
            exp_send "y\r"
            test_pass "Accepted message"
            exp_continue
        }
        -re "Commit message amended successfully!\\r?\\n?$" {
            test_pass "Amendment completed successfully"
            return
        }
        timeout {
            test_fail "Timeout waiting for prompt"
        }
        eof {
            test_fail "Unexpected end of output"
        }
    }
} 