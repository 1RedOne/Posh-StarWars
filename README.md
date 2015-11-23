# Posh-StarWars
![alt tag](https://github.com/1RedOne/Posh-StarWars/blob/master/img/frontpage.png)

A Powershell module based on the SWAPI.co API, to retrieve all the information you need from your favorite SCI FI movie using PowerShell.

#What does it do?

This very first version comes with 7 cmdlets.
````Powershell
    
    Get-Command -Module posh-starwars | select name
    ----          
    Get-SWFilm   
    Get-SWObject 
    Get-SWPeople 
    Get-SWPlanet 
    Get-SWSpecies
    Get-SWstarship
    Get-SWVehicule
    
  #What's next
  Add native image support w/ runspaces
  