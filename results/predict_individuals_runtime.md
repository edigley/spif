
R Code pulled from https://www.statmethods.net/advgraphs/ggplot2.html


```R
library(tidyverse)  

params <- c("p_1h", "p_10h", "p_100h", "p_herb", "p_1000h", "p_ws", "p_wd", "p_th", "p_hh", "p_adj")
```

    ── Attaching packages ─────────────────────────────────────── tidyverse 1.2.1 ──
    ✔ ggplot2 2.2.1     ✔ purrr   0.2.4
    ✔ tibble  1.4.2     ✔ dplyr   0.7.4
    ✔ tidyr   0.8.0     ✔ stringr 1.2.0
    ✔ readr   1.1.1     ✔ forcats 0.2.0
    ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()



```R
ds <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera.txt', header=T)
ds <- subset(ds, select=c("individual", paste("p", 0:9, sep=""), "runtime", "maxRSS"))
colnames(ds) <- c("id", params, "runtime", "maxRSS")
head(ds)
```


<table>
<thead><tr><th scope=col>id</th><th scope=col>p_1h</th><th scope=col>p_10h</th><th scope=col>p_100h</th><th scope=col>p_herb</th><th scope=col>p_1000h</th><th scope=col>p_ws</th><th scope=col>p_wd</th><th scope=col>p_th</th><th scope=col>p_hh</th><th scope=col>p_adj</th><th scope=col>runtime</th><th scope=col>maxRSS</th></tr></thead>
<tbody>
	<tr><td>1       </td><td>15      </td><td>10      </td><td> 1      </td><td>66      </td><td>84      </td><td>17      </td><td>155     </td><td>48      </td><td>32      </td><td>0.046063</td><td>1157.20 </td><td> 801428 </td></tr>
	<tr><td>2       </td><td>10      </td><td> 2      </td><td>14      </td><td>33      </td><td>89      </td><td>20      </td><td> 17     </td><td>30      </td><td>53      </td><td>0.598361</td><td>1712.82 </td><td>1006216 </td></tr>
	<tr><td>3       </td><td> 3      </td><td>13      </td><td> 4      </td><td>30      </td><td>80      </td><td> 8      </td><td>232     </td><td>49      </td><td>49      </td><td>0.416760</td><td> 138.85 </td><td> 181360 </td></tr>
	<tr><td>4       </td><td> 6      </td><td>14      </td><td>13      </td><td>48      </td><td>69      </td><td>11      </td><td> 70     </td><td>41      </td><td>41      </td><td>1.418043</td><td> 365.20 </td><td> 408428 </td></tr>
	<tr><td>5       </td><td> 3      </td><td> 4      </td><td> 4      </td><td>26      </td><td>88      </td><td> 4      </td><td> 36     </td><td>33      </td><td>45      </td><td>1.612439</td><td>  44.73 </td><td> 108748 </td></tr>
	<tr><td>6       </td><td>13      </td><td> 3      </td><td> 4      </td><td>62      </td><td>77      </td><td> 9      </td><td> 18     </td><td>32      </td><td>85      </td><td>1.266557</td><td>  24.92 </td><td>  77652 </td></tr>
</tbody>
</table>




```R
# loads random individuals data set
individualHeader <- c(params, paste("p", seq(11,21), sep=""))
individuals<-read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals.txt', skip=1, col.names=individualHeader)
individuals <- subset(individuals, select=params)
#individuals$id <- seq.int(nrow(individuals))
individuals <- tibble::rowid_to_column(individuals, "id")
head(individuals)
```


<table>
<thead><tr><th scope=col>id</th><th scope=col>p_1h</th><th scope=col>p_10h</th><th scope=col>p_100h</th><th scope=col>p_herb</th><th scope=col>p_1000h</th><th scope=col>p_ws</th><th scope=col>p_wd</th><th scope=col>p_th</th><th scope=col>p_hh</th><th scope=col>p_adj</th></tr></thead>
<tbody>
	<tr><td>1       </td><td> 2      </td><td> 3      </td><td>12      </td><td>52      </td><td>91      </td><td>16      </td><td>145     </td><td>33      </td><td>61      </td><td>1.718865</td></tr>
	<tr><td>2       </td><td>15      </td><td>10      </td><td> 1      </td><td>66      </td><td>84      </td><td>17      </td><td>155     </td><td>48      </td><td>32      </td><td>0.046063</td></tr>
	<tr><td>3       </td><td>10      </td><td> 2      </td><td>14      </td><td>33      </td><td>89      </td><td>20      </td><td> 17     </td><td>30      </td><td>53      </td><td>0.598361</td></tr>
	<tr><td>4       </td><td> 3      </td><td>13      </td><td> 4      </td><td>30      </td><td>80      </td><td> 8      </td><td>232     </td><td>49      </td><td>49      </td><td>0.416760</td></tr>
	<tr><td>5       </td><td> 6      </td><td>14      </td><td>13      </td><td>48      </td><td>69      </td><td>11      </td><td> 70     </td><td>41      </td><td>41      </td><td>1.418043</td></tr>
	<tr><td>6       </td><td> 3      </td><td> 4      </td><td> 4      </td><td>26      </td><td>88      </td><td> 4      </td><td> 36     </td><td>33      </td><td>45      </td><td>1.612439</td></tr>
</tbody>
</table>




```R
# generates the multiple linear regression model based on individuals run results
model <- lm(runtime ~ p_1h + p_10h+ p_100h + p_herb + p_1000h + p_ws + p_wd + p_th + p_hh + p_adj, data=ds)

```


```R
summary(model)$coefficient 
```


<table>
<thead><tr><th></th><th scope=col>Estimate</th><th scope=col>Std. Error</th><th scope=col>t value</th><th scope=col>Pr(&gt;|t|)</th></tr></thead>
<tbody>
	<tr><th scope=row>(Intercept)</th><td>1066.5290498 </td><td>234.7946849  </td><td>  4.5423901  </td><td> 6.283735e-06</td></tr>
	<tr><th scope=row>p_1h</th><td>  -5.2205512 </td><td>  4.7175502  </td><td> -1.1066233  </td><td> 2.687393e-01</td></tr>
	<tr><th scope=row>p_10h</th><td> -29.8225067 </td><td>  4.8735806  </td><td> -6.1192190  </td><td> 1.377548e-09</td></tr>
	<tr><th scope=row>p_100h</th><td>   8.8115581 </td><td>  4.6091873  </td><td>  1.9117379  </td><td> 5.621297e-02</td></tr>
	<tr><th scope=row>p_herb</th><td>  -1.1217462 </td><td>  1.3329475  </td><td> -0.8415532  </td><td> 4.002517e-01</td></tr>
	<tr><th scope=row>p_1000h</th><td>   0.7347450 </td><td>  1.6905287  </td><td>  0.4346244  </td><td> 6.639346e-01</td></tr>
	<tr><th scope=row>p_ws</th><td>  87.4010749 </td><td>  3.2665835  </td><td> 26.7561125  </td><td>9.201122e-118</td></tr>
	<tr><th scope=row>p_wd</th><td>   0.2408838 </td><td>  0.1858225  </td><td>  1.2963113  </td><td> 1.951858e-01</td></tr>
	<tr><th scope=row>p_th</th><td>   2.2370761 </td><td>  3.4039716  </td><td>  0.6571959  </td><td> 5.112155e-01</td></tr>
	<tr><th scope=row>p_hh</th><td> -22.6619481 </td><td>  0.9586686  </td><td>-23.6389805  </td><td> 2.281896e-97</td></tr>
	<tr><th scope=row>p_adj</th><td> -36.4179944 </td><td> 35.3428895  </td><td> -1.0304193  </td><td> 3.030777e-01</td></tr>
</tbody>
</table>




```R
predict(model, tail(individuals, 10))
```


<dl class=dl-horizontal>
	<dt>9991</dt>
		<dd>280.148600329198</dd>
	<dt>9992</dt>
		<dd>182.497611542032</dd>
	<dt>9993</dt>
		<dd>323.414346989752</dd>
	<dt>9994</dt>
		<dd>442.633464982718</dd>
	<dt>9995</dt>
		<dd>441.995032001675</dd>
	<dt>9996</dt>
		<dd>713.395297971672</dd>
	<dt>9997</dt>
		<dd>605.821404366603</dd>
	<dt>9998</dt>
		<dd>1523.9211762348</dd>
	<dt>9999</dt>
		<dd>932.250824581171</dd>
	<dt>10000</dt>
		<dd>1117.58232342805</dd>
</dl>


