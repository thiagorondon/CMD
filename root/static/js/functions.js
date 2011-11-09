var last_year = 2010;

function getNode(id) {
	var url = '/data/node/' + id;
	geturljson(url);
}

function geturljson(url,year) {
	last_url = url;
  $('.voltarpagina').hide();
  $('.carregando').show();
	$.getJSON(url, function(rdata) {
    $('.carregando').hide();
		$('.my-new-list').empty();
  		var data = rdata.data;
		if (rdata.children != ""){
			showData(data,rdata,url,year);
      $('.legenda').show();
			$('.total').html("Total: R$ " + rdata.total_tree);
			if (rdata.zones != undefined) {

        var list = $('.intro').append('<ul class="breadcrumb">').find('ul');
        for (item in rdata.zones_a) {
          if (item == rdata.zones_a.length - 1) {
          list.append('<li class="active">' + rdata.zones_a[item].content + '</li>' + "\n");
          } else { 
          list.append('<li><a href="/node/' + rdata.zones_a[item].id +'">' + rdata.zones_a[item].content + '</a> <span class="divider">/</span></li>' + "\n"); 
          }
        }

        $('.voltarpagina').show();
      } else {
				$('.intro').html("<p>Esta disposição é baseada na lei de diretrizes orçamentarias e os dados são do portal da transparência, no qual estão apenas os investimentos realizados pelo governo federal. </p>");
        $('.voltarpagina').hide();
			}
		}
		
		else{
			document.location.href = "/year/" + rdata.current_model;
		}
	});

}

function showData(data,rdata,url,year) {
	OpenSpending.DatasetPage.init({
	        treemapData:  rdata
	});
	
	var items = [];

	items.push('<table id="datalist" class="tablesorter" width="95%" align="center"><thead><tr><th>Descri&ccedil;&atilde;o</th><th>Total de gastos</th><th>Porcentagem nesta vis&atilde;o</th></tr></thead><tbody>');
	$.each(rdata.children, function(key, val) {
		items.push('<tr class="alt"><td width="320">' + '<a href="' + val.data.link  + '">' + val.data.title + '</a></td><td align="right">R$ ' + val.data.valor_tabela + '</td><td align="right">' + val.data.porcentagem + '%</td></tr>');
	});
	items.push('</tbody></table>');

	items.push("<br />Formato aberto dos dados listados nesta página em JSON: ");
	items.push("<a href='" + url + "' target='_blank'>http://www.paraondefoimeudinheiro.com.br" + url + "</a><br />");
	
	$('.my-new-list').html(items.join(''));

	var myTextExtraction = function(node)  
	{  
	    // extract data from markup and return it  
		var conteudo = node.innerHTML;
		if (conteudo.search("href") < 0){
			conteudo = conteudo.replace(" ","");
			conteudo = conteudo.replace("R$","");
			conteudo = conteudo.replace("%","");
			conteudo = conteudo.replace(/\./gi,"");
			conteudo = conteudo.replace(/\,/gi,".");
			conteudo = parseFloat(conteudo);
		}else{
			conteudo = node.childNodes[0].innerHTML;
		}
		return conteudo;
	} 	
	$.tablesorter.defaults.sortList = [[1,1]]; 
	$.tablesorter.defaults.textExtraction = myTextExtraction; 
	$("#datalist").tablesorter();

}

function changeYear() {
	var url = '/year/' + $('#year').val();
	window.location.replace(url);
}

