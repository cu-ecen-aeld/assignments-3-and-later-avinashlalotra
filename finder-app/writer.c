#include <syslog.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, const char **argv) {
    // Initialize syslog
    FILE *file;
    size_t byte_written;
    openlog("my_program", LOG_CONS | LOG_PID | LOG_NDELAY, LOG_USER);

    // Check for valid arguments
    if (argc < 3) {
        // Log an error message to syslog
        syslog(LOG_ERR, "Usage: %s <filepath> <text_string>", argv[0]);
        
        // Close syslog
        closelog();
        
       // Exit with an error code
        return 1;
    }
    file = fopen(argv[1],"w+" );
    if (file == NULL ) {
	syslog(LOG_ERR,"Unable to create a file");
	return 1;
	}	
   byte_written = fwrite(argv[2],sizeof(char),strlen(argv[2]) ,file );
   if (byte_written != strlen(argv[2])){
	syslog(LOG_ERR,"Unable to write file");
	return 1;
	}
   fclose(file);
    // Close syslog if arguments are valid
    closelog();
    return 0;
}

