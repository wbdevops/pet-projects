import re

#Define the pattern of the entire log string, and what needs to be cut from the log line.
obj = re.compile(r'(?P<hostname>.*?)\s+(?P<ip>.*?)\s+-\s+(?P<remote_user>.*?)\s+\[(?P<time>.*?)\]\s+"(?P<request>.*?)"\s+(?P<status>.*?)\s+', re.IGNORECASE)

def load_log(path):

    iteration_nr = -1
    result_list = []
    list_number = 0

    with open(path, mode="r", encoding="utf-8") as f:
        for line in f.readlines():
            
            result = {}
            list_number +=1

            #Remove white spaces from the start as well as the end of the line
            lines = line.strip()

            #Get what falls under the obj pattern above
            results = re.search(obj, lines)
            
            result['host'] = results.group(1)
            result['code'] = results.group(6)
            
            #Check if the host and response code belong to the list
            if result not in result_list:
                #uncomment to check line number
                #print(list_number)

                iteration_nr += 1
                result_list.append(result)

                #Write a unique host and response code into file
                p = open(parsed_log, "a")
                p.write(f"Host: {result_list[iteration_nr].get('host')}, Code: {result_list[iteration_nr].get('code')}\n")
                p.close()
                #Uncomment to print result into console 
                #print(f"Host: {result_list[iteration_nr].get('host')}, Code: {result_list[iteration_nr].get('code')}")

        #result_list = sorted(result_list, key=lambda d: d['host'])
        #print(result_list)

    f.close()

if __name__ == '__main__':
    parsed_log = "parsed_log.txt"

    print("Processing...")
    load_log("nginx-access.log")
    print(f"Done, the result stored in {parsed_log}")