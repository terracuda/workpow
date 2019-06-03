#Author:  https://github.com/terracuda/workpow
                   
				   #Welcome message
clear-host
echo ""
echo " ___________________________ "
echo "|                           |"
echo "|       Powerbot v1.7       |" 
echo "|     Author: TerraCuda     |"
echo "|___________________________|"
echo ""

                   #Variables
$BotToken = "481745821:AAF1WitceQhjdfMOfYWOYM-pgVylomXKtm1A"  #bot_token, e.g: "481745821:AAF1WitceQhjdfMOfYWOYM-pgVylomXKtm1A"
$ChatID = 250914301                                         #ChatID with bot, e.g: "250914301"
$LoopSleep = 3     #Time to sleep for each loop before checking if a message with the trigger-word was received
$maxlength = 4090  #Maximum allowed length for one part of the message

                   #Get and show bot information
$botinfo = ((Invoke-WebRequest -Uri https://api.telegram.org/bot$BotToken/getMe).Content | ConvertFrom-Json).result
$botid = ($botinfo).id
$username = ($botinfo).username
$firstname = ($botinfo).first_name

Write-Host "Username:" $username
Write-Host "First name:" $firstname
Write-Host "Bot ID:" $botid
Write-Host "Connected. Checking for new commands every $LoopSleep seconds."

                   #Get the Last Message Time at the beginning of the script:When the script is ran the first time, it will ignore any last message received!
$BotUpdates = Invoke-WebRequest -Uri "https://api.telegram.org/bot$($BotToken)/getUpdates"
$BotUpdatesResults = [array]($BotUpdates | ConvertFrom-Json).result
$LastMessageTime_Origin = $BotUpdatesResults[$BotUpdatesResults.Count-1].message.date

                   #Read the responses in a while cycle
$DoNotExit = 1
                   #$PreviousLoop_LastMessageTime is going to be updated at every cycle (if the last message date changes)
$PreviousLoop_LastMessageTime = $LastMessageTime_Origin

$SleepStartTime = [Int] (get-date -UFormat %s) #This will be used to check if the $SleepTime has passed yet before sending a new notification out
While ($DoNotExit)  {

  Sleep -Seconds $LoopSleep
                   #Reset variables that might be dirty from the previous cycle

  $LastMessageText = ""
  $CommandToRun = ""
  $CommandToRun_Result = ""
  $CommandToRun_SimplifiedOutput = ""
  $Message = ""
  
                   #Get the current Bot Updates and store them in an array format to make it easier

  $BotUpdates = Invoke-WebRequest -Uri "https://api.telegram.org/bot$($BotToken)/getUpdates" -ErrorAction SilentlyContinue
  $BotUpdatesResults = [array]($BotUpdates | ConvertFrom-Json).result
  
                   #Get just the last message:
  $LastMessage = $BotUpdatesResults[$BotUpdatesResults.Count-1]
                   #Get the last message time
  $LastMessageTime = $LastMessage.message.date
  
                   #If the $LastMessageTime is newer than $PreviousLoop_LastMessageTime, then the user has typed something!
  If ($LastMessageTime -gt $PreviousLoop_LastMessageTime)  {
                   #Looks like there's a new message!
    
                   #Update $PreviousLoop_LastMessageTime with the time from the latest message
	$PreviousLoop_LastMessageTime = $LastMessageTime
                   #Update the LastMessageTime
	$LastMessageTime = $LastMessage.Message.Date
                   #Update the $LastMessageText
	$LastMessageText = $LastMessage.Message.Text
	
	Switch -Wildcard ($LastMessageText)  {
	  "run *"  {   #Important: run with a space
	   	$CommandToRun = ($LastMessageText -split ("run "))[1]    #This will remove "run "
		$Message = "Ok $($LastMessage.Message.from.first_name), try to run the following command: `n<b>$($CommandToRun)</b> `nPlease wait.."
		$SendMessage = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($BotToken)/sendMessage?chat_id=$($ChatID)&text=$($Message)&parse_mode=html"
		
                   #Run the command
		Try {
		  Invoke-Expression $CommandToRun | Out-String | %  {
		    $CommandToRun_Result += "`n $($_)"
		  }
		}
		Catch  {
		  $CommandToRun_Result = $_.Exception.Message
		}

		
		$Message = "$($LastMessage.Message.from.first_name), I've ran <b>$($CommandToRun)</b> and this is the output:`n$CommandToRun_Result"
        $charcount = $Message | Measure-Object -Character
        $curlength = $charcount.Characters
        

                  # 
if($curlength -gt $maxlength ) {

        $chunks = [math]::Truncate($curlength/$maxlength)
        $message | Out-File temp.txt 
        $bytes = Get-Content temp.txt -Encoding byte

        for ($i=0; $i -le $chunks; $i++)
{
        $start = $i*$maxlength*2
        $end = (($i+1)*$maxlength)*2-1
        $chunk = [System.Text.Encoding]::Unicode.GetString($bytes[$start..$end])
             
        $SendMessage = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($BotToken)/sendMessage?chat_id=$($ChatID)&text=$chunk&parse_mode=html"
        Start-Sleep -m 400
}
Remove-item -Path .\temp.txt
                               }

else  {
		$SendMessage = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($BotToken)/sendMessage?chat_id=$($ChatID)&text=$($Message)&parse_mode=html"
	  }
}
	  "quit_script"  {
                   #The user wants to stop the script
		write-host "The script will end in 5 seconds"
		$ExitMessage = "$($LastMessage.Message.from.first_name) has requested the script to be terminated. It will need to be started again in order to accept new messages!"
		$ExitRestResponse = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($BotToken)/sendMessage?chat_id=$($ChatID)&text=$($ExitMessage)&parse_mode=html"
		Sleep -seconds 5
		$DoNotExit = 0
	  }
	  default  {
                   #The message sent is unknown
		$Message = "Sorry $($LastMessage.Message.from.first_name), but I don't understand ""$($LastMessageText)""!"
		$SendMessage = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($BotToken)/sendMessage?chat_id=$($ChatID)&text=$($Message)&parse_mode=html"
	  }
	}
	
  }
}