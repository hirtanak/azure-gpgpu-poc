# azure-gpgpu-poc
Azure Resource Manager Templates for GPGPU アプリケーション用のAzure ARMテンプレートです

<table>
<td align="center">
Altair nanoFuildX, ultraFuildX追加
<br><br>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhirtanak%2Fazure-gpgpu-poc%2Fmaster%2Fazuredeploy_gpgpu01.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
</td></tr>
</table>

注意点
- Azure NC24v2/NC24v3用テンプレートです
- Azure NC24v2/NC24v3の展開されているAzureリージョンは、確認する必要があります。（テンプレートのデフォルトは米国中南部）
	- このURLで確認 https://azure.microsoft.com/en-us/global-infrastructure/services/?products=virtual-machines
- NCv2などプロダクト事にQuota（CPUコア数による利用数の上限）があり、NCv2/NCv3の場合、利用前に増加させる必要がある。「Microsoft Azure のクォータ増加について」　https://blogs.msdn.microsoft.com/dsazurejp/2013/10/22/microsoft-azure/
