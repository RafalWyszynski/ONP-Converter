# Odwrotna Notacja Polska(ONP) - Converter 
# Reverse Polish Notation(RNP) - Converter
My Assemblyx86 Project at University. It contains a lot of procedures checking the correctness of the equation. Here are the most interesting functions: 
> The program catches 8 different types of errors in the equation before proceeding with the conversion. It distinguishes them and displays errors as a message on the console.
> It has procedures delay and delay2, making display of messages clearer and imitating  "thinking" of the computer.
> If any entered number exceeds the maximum 16-bit value, the program catches it and informs the user.
> If during the calculations, at any stage, the number exceeds the maximum 16-bit value, the program detects it and informs the user.
> The program allows you to start next conversion without turning off and on the programme, thanks to three buffers that clean the input and output queues.
> If the result of calculations is negative, the program can display it.
> Has a usSpaces procedure that removes all spaces from the equation before converting.
