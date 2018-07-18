#TimeBomb
Write-Host "You have 20 seconds left" -ForegroundColor Yellow
Start-Sleep -Seconds 20


#Class with constructor
class FantasticPowerShellCake
{ 
  #Constructor without values
  FantasticPowerShellCake()
  {}

  #method 
  [string] returnSomething()
  {
    return "something"
  }
}

#Instanciate
$fantasticPowerShellCake = [FantasticPowerShellCake]::new()

#Instance
$fantasticPowerShellCake

#Taking a look at the type
$fantasticPowerShellCake.GetType()
$fantasticPowerShellCake | Get-Member

#Method
$fantasticPowerShellCake.
$fantasticPowerShellCake.returnSomething() 









############################################################################



#Class with constructor
class SecretStorer
{ 
  #Constructor without values
  SecretStorer()
  {
  }

  #Constructor with values
  SecretStorer([string]$secretString, [int]$secretInt)
  {
    
    $this.secretInt = $secretInt
    $this.secretString = $secretString
  }

  #Property - string
  [string]$secretString

  #Property - int
  [int]$secretInt

  #method 
  [string] returnSomething()
  {
    return "SecretString: $($this.secretString) $([System.Environment]::NewLine)SecretInt: $($this.secretInt)"
  }

  #method for string
  storeSecret([string]$secret)
  {
    $this.secretString = $secret
  }

  #Method - overloaded for integer
  storeSecret([int]$secret)
  {
   $this.secretInt = $secret
  }
}

############################################################################

#Instantiate
$instance = [SecretStorer]::new()

#Instance
$instance

#Instantiate with values
$instance = [SecretStorer]::new('PowerShell is great!',1337)

#Instance
$instance

#Properties
$instance.secretInt
$instance.secretString

#Properties - validating types
($instance.secretInt).GetType()
($instance.secretString).GetType()

#Store
$instance.storeSecret('PowerShell is awesome!')

#take a look at the properties
$instance.returnSomething()

#Store
$instance.storeSecret(1338)

#take a look at the properties
$instance.returnSomething()

#ToString() automatically returns the name of the type
$instance.toString()

############################################################################

#Polymorphism
"string".GetType() 
"string".GetType() | Select-Object * | Out-GridView
"string".GetType() | Select-Object * | Get-Member Declared*

############################################################################

#Class with constructor
class SecretStorerv2 : SecretStorer
{ 
  #Constructor without values
  SecretStorerv2(): base()
  {  }

  #Constructor with values
  SecretStorerv2([string]$secretString, [int]$secretInt): base([string]$secretString, [int]$secretInt)
  {  }

  #Method - override toString() method
  [string] ToString()
  {
    return $this.returnSomething()
  }
}

############################################################################

#Instantiate with values
$instance = [SecretStorerv2]::new('ToStringTest',1234)

#Call method
$instance.returnSomething()

#ToString() is now overloaded with our specified method - 3 examples
"$instance"
$instance.toString()
$instance


