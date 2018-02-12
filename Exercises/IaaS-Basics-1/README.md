# IaaS Basics Exercise 1

The goal of this exercise is to set up two identical virtual machines which will host a REST-Api website in IIS and distribute requests equally across both nodes.

The following chapters give you a brief description of what you need to set up and configure. Follow the step-by-step guide and do necessary research to accomplish the notes tasks.

## 1. Set up a virtual machine

1. Create VM from Marketplace template
    * Template to use: *Windows Server 2016 Datacenter*
    * Put VM into new [Availability Set](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-availability-sets) when asked during creation process
    * VM size: Use a small general purpose sized VM with only 1 vCPU. See [explanation of available virtual machine sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes) to find an appropriate size.
2. Login to VM via RDP
3. Install IIS and Web Deploy. Configure VM to support Web Deploy based Deployment
    * [Guide with script to install IIS, WebDeploy and configure VM](https://github.com/aspnet/Tooling/blob/AspNetVMs/docs/create-asp-net-vm-with-webdeploy.md#patch-an-existing-vm)
    * Assign DNS name to VM (required for Web Deploy based deployments)
    * Configure NSG to allow public access via Port 80 and Port 8172 (Web Deploy)
4. View default website via browser to check public availability
5. Deploy simple web service/API that runs several seconds per request
    * Deploy it from within Visual Studio using Web Deploy. Follow this [guide](https://github.com/aspnet/Tooling/blob/AspNetVMs/docs/publish-web-app-from-visual-studio.md).
    * We suggest to implement API accepting a GET-Request like ```/api/compute/{int-value}``` which computes the fibonacci sequence using recursion. (Values around 43-48 should result in run times of 5-30 seconds).
    * You may use this example web app or feel free to implement your own REST-Api. Only constraints are, that it must run in a default IIS installation and accepts he requests via HTTP GET.

## 2. Setup second VM for Load Balancing

1. Create second VM exactly like first one
    * During creation put it into same Availability Set
    * Deploy your web application into the default IIS Web Site, too.

## 3. Setup Load Balancing VMs

1. Create Load Balancer (Choose SKU *Basic* if you have the choice - as of February 12 2018 the SKU *Standard* is still in non-public preview, so you cannot choose).
2. Setup the LB with a public IP.
3. Create new backend pool.
4. Associate this backend pool with your availability set.
5. Assign first IP address of each VM of that availability set.
6. Create Health Probe to check VM healthiness via TCP Port 80.
7. Create Load Balancer Rule for Port 80.

## 4. Verify that Load Balancing is working

1. Run [this script](Measure-API-average-response-time.ps1) with parameter *-Url* to send 10 concurrent requests a single VM.
2. Run the script again but this time use the URL pointing to your Load Balancer.
    * You should see that the response times are shorter in average, i.e. roughly half the time compared to the single VM.
