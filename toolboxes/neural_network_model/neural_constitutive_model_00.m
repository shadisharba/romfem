function [Y,Xf,Af] = neural_constitutive_model_00(X,~,~)
%NEURAL_CONSTITUTIVE_MODEL neural network simulation function.
%
% Auto-generated by MATLAB, 01-Aug-2019 03:45:02.
% 
% [Y] = neural_constitutive_model(X,~,~) takes these arguments:
% 
%   X = 1xTS cell, 1 inputs over TS timesteps
%   Each X{1,ts} = 14xQ matrix, input #1 at timestep ts.
% 
% and returns:
%   Y = 1xTS cell of 1 outputs over TS timesteps.
%   Each Y{1,ts} = 14xQ matrix, output #1 at timestep ts.
% 
% where Q is number of samples (or series) and TS is the number of timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [-25.7322968526047;-9.87223866308078;-121.658602330608;-3.90705740068189;-44.6169371936453;-3.05786705698925;-0.109580809594362;-0.115466455427031;-0.240014539468504;-0.00188473190180457;-0.0476871464057174;-0.0024691558839051;0;0];
x1_step1.gain = [0.0388614914523455;0.102945869297991;0.00825549577004521;0.256456376658595;0.0223993070889513;0.326848159378107;8.92448477136431;8.3001592745333;4.30050367648166;399.072804221719;22.6647079009894;329.642448588473;47.0418330923154;514493.538527311];
x1_step1.ymin = -1;

% Layer 1
b1 = [-4.7250558545704146596;0.74507979547849156887;-1.0577931379623459751;-1.9609471397864435271;1.3216885747497721937;2.4982001226125380988;-0.59322125615698806378;5.5441449656064865081;-0.40675536563460568118;-0.101668106805025249;0.16611869260210485044;0.15602478722559295909;0.43399746753082085737;0.27352679288277570446;-0.61884037254119550475;0.44464692125019711355;-0.37695156896121717605;-0.095638489276292121266;0.017449502589960828869;-0.89446514908174634684;-0.61698555829249668303;1.3012265372349296477;-3.2325996534776835212;2.4472597841180996348;4.3499066110361219728;-0.48202822649384541309;0.78767254365452499254;-3.2395993990708054078];
IW1_1 = [0.23935247404804860238 7.5960761489913576627e-05 -4.221241985105898209 -0.63619357086835492954 0.43421701707234050538 0.11373820528857024603 -0.41151141526193552034 0.47171131051167608517 -0.046106819882944391487 0.08407008694297010698 -0.1889411263012487352 0.053736906636479037092 0.94407768602298891558 -0.76718076141592561612;0.096156354377687075496 -0.10101291431019963907 -0.6590586397764611748 -0.083248343030690702404 -0.40394498341018236776 0.10283817643169658462 0.53105585536480637288 -0.70998957688815411693 0.1119580752956129549 -0.099759872247296738079 0.082570855097498688235 -0.11597100708469583463 -0.97065694991204898301 0.69760417678047814682;0.10585027565876525824 -0.046422224279410957692 0.6971089583056152561 -0.2521051622204820708 -0.66657633331894772244 0.044474949868247758145 0.36871720583581929498 -0.68412344963619442506 0.17678346253518356646 0.051958643835727687244 0.33135007051226950114 0.033273357346853951744 0.13099388167594763765 -0.12140943544707412383;0.67475008107991885087 -0.79708085918233118061 -0.41203461888557002535 -0.77675790292828150729 -0.054554042490418459821 0.40801054267127773167 -0.17745709582464819221 -0.33749532849908397969 0.26037667517916845972 0.37699214327620395037 -0.19418520479257439515 -0.080821992870083445015 1.3271511830127773468 -1.512243474830689216;0.27542458377305101269 -1.1578710782255581258 -0.0092369008169347188025 -0.59938064160763182553 -0.54765168293643873287 -0.6299885126201434371 0.1481477078185290952 -0.23411273532613829929 0.049910412877937654352 -0.20569947713567640624 0.044310344433782546114 -0.26299980011975487848 -1.5616975652986102574 0.96536229193592215658;0.15446829002074935477 -0.14059386702177262274 -0.10559239899176538213 0.27930118855322683125 0.1686225403023428604 0.83999156831512011845 1.1898409707361141674 -1.0020081387675281448 -0.054192237180474521485 0.32386454767607908423 -0.088855200683791366045 -0.043553587922562038426 0.84522450277622895864 -0.10847125624116504827;-0.19624295862920876354 0.15162406991513172061 0.34760399710664507955 -0.25086607568174057459 -0.031549811742652152102 -0.52068762558955994368 -0.43056494821135027351 0.4395162030782277518 -0.020243510677386354624 -0.23402014069007825992 0.042751551832457400371 -0.3082063928240952877 -1.461607765273118309 0.69245972125965316035;-0.26267138397924449933 -0.23388918953536400047 5.2741091851394141798 -0.39936910972270112108 -0.16631160693554480901 -0.018757315767701929904 1.2055632909791360596 -1.2065896036980006123 0.044228420461173020839 -0.061383530894153853774 0.08481302178521082924 -0.024898744588994325966 0.19464325953702862892 -0.1847718394501293715;0.29558263455222127947 -0.067678674160790083802 -0.34559349745015588429 -0.67333240817395989541 -0.43075554013382599816 0.062295750937922875212 -0.39659906229093189189 0.42948700309460596802 -0.031415335668130123237 0.14834465843123656459 0.033681812900179693149 0.090925462185621544475 0.42701080982491379512 -0.12606287842035773794;0.19828932641696372929 0.014587917840015045962 0.11395805282603337083 0.25795156324995222041 1.1922067205577813187 -0.071137074766538910264 -0.25482966273033424986 0.46324213560756899444 -0.11721910035364625779 0.20054630319858407494 0.01038299199269120815 0.18053501113967751479 2.2212168402230028086 -1.5898560097656326828;0.24012930749443356371 -0.23110187654070016294 -1.648797744035376045 -0.32216127207631556351 -0.73411959799469117538 0.3543307292654880869 0.77088426609816840251 -0.96073402869070023691 0.12630636239817502608 -0.10281789353830159128 0.324505969881712375 -0.10083240903502890817 -0.46331779711010295797 0.23021577347466151697;-0.71614088159624478269 -0.45660108265640292347 0.81212878850246694729 -0.98386583503982094623 2.0734860629750282435 -0.012730228990687845678 0.083523940956251374601 -0.018177783246766450465 -0.030830040307341821659 -0.66913571397126814233 0.40031669273009878873 0.99220489699037728304 -1.2501185741436877663 1.0822080001082345913;-0.29325210079740027247 0.2103029080467969103 -0.89022402654279630951 0.42452034049546749639 -0.53243111542065046926 0.57171363448918877115 -0.45973994521773459132 0.53207348650660823974 -0.054141411912676309925 -0.33000524441351569704 -0.20571680025927963076 0.30955054918258423369 -0.1265290405865615031 0.18397819818416821791;-0.30807954191581427006 -0.060128408820736188589 -2.1186208907538652824 -0.024599342724447362946 -0.0082741437239311366875 -0.078001906969115478163 -0.078740424438383027628 0.031319486476953560528 0.021715883167360821443 -0.04385596894977379645 -0.074485036342613386573 -0.13758201694794863768 -0.67984179525623822382 -0.1960491971036877612;0.21117093346657733743 -1.0027777839745204425 0.99934815085138228863 -0.90398935125675794477 -0.8120936255032501494 0.79079544264349133087 0.25472200996354849023 -0.61326545432662304957 0.19500199057268000069 1.0593163006585146757 1.3192279637019530547 -1.1726810205567437251 -1.013770050955288049 1.0320353637198169672;-0.053725499380410345063 -0.20158869132541371028 0.66727976070292094324 0.098753752609287120956 0.38126995620205567095 0.050994049395937685043 0.065833255296064707718 0.055891331798319295043 -0.060681986560069303693 0.064727516510972096797 -0.010405053139632960621 0.12469082660442601385 0.53337401689764019075 -0.12340754056243469217;0.14522977308135617824 0.099955190130015345029 0.36850082726077210138 -0.81659832639462326398 -0.22268046121592063868 0.57824270959546719695 0.068150258225721641048 -0.027952746724924860261 -0.018357541596475433071 0.077334988490789957627 0.47289841223428424888 -0.86395401178441755263 -0.31908292970373824948 0.4207318172273085688;-0.19187289246394445552 0.16524081175533172905 -0.030020929070215862655 -0.068233532126717483246 0.040101396482883584771 -0.22805701886918994248 0.026705151281455046658 -0.15036401185459999374 0.065038123885750018238 -0.11914756411042788653 0.12649614268507528014 -0.175039918133876371 -1.8939436668407390041 1.5195370561487766548;0.19731112394234526231 0.0026786013303976953862 -1.2212935247956526741 -0.27680137015756894892 -0.063928386714041662842 0.10934401696743716037 -0.35929364249717449242 0.29277608632763579832 0.021441401855584633213 0.25596338591729855816 -0.018653458903181409367 -0.43104235517023131719 -0.90874588790839194719 0.39858689820347481536;-0.27076067945270576587 -0.23566146418038536048 -1.3420063263907511253 -0.51118522732383964158 -0.49356774587469592896 -0.65926405581820057833 -1.548597237122350645 1.3628158448128124824 0.040127420428006099762 -0.26035639108295616229 0.11909396975394227758 -0.2480153462618983895 -1.2768502042524012552 0.49932807732798989431;-0.19014264188730653493 0.28315530744914507721 0.33436357468964134076 0.45903376680763002815 0.37347348918232031734 0.30171726482696131777 -0.56369512162556101309 0.66809248632119511146 -0.074521965136436107979 0.058517856353410238612 -0.074318066985712236128 0.14309922140540790036 -0.56112331247944391421 0.73714032570120147092;-0.04801009311337589569 -0.23290223917474320303 -1.3566637643698995497 0.18801358400214493449 -0.23807709600672352646 0.77281117144754052362 -0.39813925622874302146 0.36627575605323287045 0.0020783673059792690668 -0.20486751468059039016 -0.0010726700333602667663 -0.12382338961266334265 0.10724816386850091754 -0.48712138010475741767;0.7604483142508519089 -0.1123775244608777174 -2.6490615253135745277 0.18186388008098522406 0.2356958603416355047 -1.1061942697862205964 -3.010057259508838623 3.1030340867640195945 -0.15727582138159132419 0.11981565090199847168 -0.14259631917512316512 0.20443292105708429918 0.58683111509553065321 -0.48607410603121897763;0.48184923411647156977 -0.49105557018199347263 0.24095403229311521121 -0.53431848144698868008 0.21060563875548404811 -1.1448282677896690629 0.38722768765233778199 -0.41791728184184501194 0.029936034231272980188 -0.059285554159779201011 -0.248142304714462969 -0.054302102751254292812 -0.54620433557959713333 1.1838963833422331273;0.089968820718525868707 0.19794717285994828382 -4.0821225224358244077 -0.084836525449262276122 0.46820551926662756781 0.072844665540851907815 0.11168827150125128223 -0.20169154639751793456 0.050681105956766642207 -0.11533072308450903476 0.11013704583305755635 -0.0018594014574601410578 0.3416327458101262593 -0.39693316382045340518;0.10152777143521109215 0.028087182052858004899 -1.5735490680473485092 -0.31887854332106346789 -1.1868726884697902157 0.11150880636689083913 -0.41325328191311477832 0.12690345956851822873 0.1333860788019454735 -0.11088606976060891296 0.031789766862375744283 -0.0083338008453629677103 -0.9432997509697239602 0.80979513404513769892;-0.21573464819317858532 -0.177271206717607821 0.048302389563566715258 1.9279021787289452039 0.22541401486172510382 -0.36818990735108098056 -2.6825017976674310205 2.053406444418896637 0.22871896203609795584 -0.45055268118784225218 -0.051668172920969465678 0.14002518532601113121 -2.4775054878462468011 2.2086374788096958532;-0.74419126276965164024 0.036527136560445420954 3.2924710394548775128 -0.23169139499147003991 0.74481517726797541457 0.13268626713092107616 0.12007154890208567022 -0.10033661322233310143 -0.0058729764094995508261 0.010027092148775985925 0.021238810186816847042 0.09933201777886255246 1.5159190861973443898 -1.3469929161372373727];

% Layer 2
b2 = [0.08673787207417718581;1.3510252341724267033;-0.28669628666740248901;-0.045116485058943431308;1.5709024745709789794;-1.3408376799462691231;2.3519571241236909565;-0.64856917056662477528;1.2491947899865891713;1.1912388177471719963;1.5732012167808713254;0.63207504773945633048;1.1860466649958563146;2.2775172785011417176];
LW2_1 = [-0.32419946899784551908 0.65365410651202826564 -0.12747345264337375803 -0.10268358734541387089 0.1267135228740532138 0.20849317789982713123 -0.14766060976824346707 -0.14553104554329293618 -0.39038580053683813453 0.2898135411687470242 0.068645085134309807851 0.082476149493611192187 -0.054873372724062043082 -0.10560633696325849584 0.060095827297801197864 -0.20157176230369824865 -0.066309010044392033278 0.56898713126442890253 -0.36796600913777610664 0.13407404783047399688 -0.0074155697241323941318 -0.014320449995696078391 -0.31705161730871184167 0.1747559578569541916 -1.0415840995828173909 0.26401807760552142845 -0.26305657432129142537 0.71522440040032808639;0.4662777521387372337 0.86667772586151126113 0.028035697239510725537 -0.17091272071490440365 0.08135623999347234292 -0.094255430437229684171 0.017027244044465303374 -1.4245875405314973872 0.16757099285171261904 -0.030081881377804209343 0.1613648835761279654 -0.013745139972682725998 -0.17324962533229004702 0.28609909411998435402 -0.00016672958549256156058 -0.44451898508770099072 0.099680297326814382153 -0.3381911576212490167 -0.36789630550738444681 0.14645171069458867708 0.77063455711223283195 0.35826877537183254852 -0.89554032698075125563 0.67019515159071796351 -0.93864665131329783065 -0.2979288568423802408 0.051688742674707514879 0.65554327524281419404;-1.467596582869971078 -0.35881733126001141843 0.45550470031691953077 -0.32827633146680718079 -0.075601141064541077519 0.19732879662922275799 -0.070623497571657617433 0.1808819525371128667 -0.56845849642307078042 -0.4280399627556097375 -0.088045583399302448924 0.018647225028208914283 -0.1331145725168263183 0.41690800944217193402 -0.020191640555847382293 -0.13709404238698982836 0.23043943705019764856 -0.27907382040046091465 -0.25665670629795522828 0.12753965136098963096 0.75565545122966693015 0.53610258678100719543 0.77337859926840990532 1.1492220200238361105 -1.4207363726063817477 0.40397842466401223671 -0.048398092361374142611 0.66819672605205460147;0.26332824943224675263 0.34948726997079054835 0.58255533529191361186 -0.085102219450828672787 0.037417742318389693446 0.21339367893645308505 0.37647278593915495248 1.4449774686239165167 -1.2071564051113368166 0.63424220746529014203 -0.24490140476626282018 0.07410547691544243365 -0.19282707943004567808 0.58052338284066196117 0.040305888461250015398 0.19638762573045737136 0.051928123425340588781 -0.3980812836296555024 -0.47386668299426232265 0.043958843382082148088 0.090196008860682463926 0.37451933183060237553 -0.015143584485883328228 -0.77775896425520751887 -1.7771243290099294487 0.62451055031436120135 0.40003559479252592812 -0.047628465767610532466;0.19091308247966282119 -0.40126623719417997549 -0.15394323379762703263 -0.1786097342744983052 -0.031413397997984190968 -0.084941246340418954941 0.013765873213756951027 -0.88512870841029611668 0.51345396175897495272 -0.15937443194166062144 -0.44679856492332076234 0.0035496003198926067389 0.41768029550299451413 0.24447184037153976699 0.09745549963448367492 -0.30099630038872737803 0.020066488567295089757 -0.031587174853710785205 -0.17436641681549741589 -0.015535631350953491361 -0.59564633860718763092 0.10369170153160854608 -0.0028473592079743229206 0.00079590978807097569059 -1.1963303349952125743 -0.046542384240123253758 0.10316946045595880299 -0.29192951590478233292;-0.28549468079053974545 0.41210649514932418125 -0.27407234805385427556 -0.21425048087659995244 -0.43491739067893248061 0.0066627374910194223437 0.032307765458625736787 -0.1863915858515771129 0.13371590318718670765 0.16969607969881053688 -0.073139164290851030326 -0.045097316186882750733 0.039674429774892674971 0.21291203380347897833 -0.016627818013069787378 0.003999487395507546339 0.094795171204038977675 0.10028267736824700296 -0.24635944425708353189 0.0086310510744585944992 -0.42246825583192015863 0.17824567682770695032 0.08091852841661861806 -0.11968460541076547665 0.28343330199829908089 -0.15491783477815809777 0.32552951533821578023 -0.085283957838270599283;-0.097293546798786878504 -1.4242936111317137104 -0.43421891838914777884 -0.0039711881447611532131 -0.44499504874709333579 -0.29334300120842426995 -0.40725808057098361603 0.40126190684304313683 0.38614195047047711329 -0.55597019028692862275 -0.61947686307769078695 -0.10641477313276964667 -0.33665600011807261804 -0.88770508464098463186 0.1451501538514949341 0.059936991866116416661 -0.11052255254468977552 0.76824787504327274323 -0.58095134351714183829 -0.16495876659265029662 -0.9532655042546677171 0.46247921416542198125 0.57670379128783577638 -0.90000588910628598338 0.6637037912482552926 0.71267813063340246238 -2.0309686461959484127 -0.14948996634288944096;1.0536396253291107072 0.99241110552564981706 -1.28329579428319418 -0.17046881505776428911 -0.20310180164717045459 -0.28392293315824573829 -0.43576050776970304268 -2.3184222673333199083 0.94020988800423865861 -0.12049152326863456219 0.15044768157745569415 -0.030450100128430274138 0.36186929269589623859 -0.020032765151787979008 -0.00082649043140290486421 -0.98928061719403759255 0.053788954731941937548 0.6081278063936645939 -0.50544850128416529689 -0.18555497054076519614 -1.1261185204511754421 0.80964977038487162542 -0.0097782188647183680696 0.61823949257560484316 0.30291508319377630221 -1.1339675749730493415 0.2251307329783306943 0.0559831832746695221;1.2336311623391946757 -0.51784786642121605205 -0.34613416163777910306 -0.31140689758113337948 -0.18194229276532775108 0.99719304748828141438 -0.13248637381933642265 -0.077272778397651523119 0.58122627385905556441 -0.17890458484083576751 0.58411130448627590628 -0.011945185239054637721 0.15273270708628317038 0.0048515709311326296951 0.051637045307815779283 -0.46040525210141075574 -0.12384183886089231152 0.77831128707202601458 -0.31956609225825105547 -0.24443779406999155412 -0.93499966366872855339 -0.018009752456572429569 0.28749677978683629842 0.08410438223175388528 -1.0773638100179805388 -0.6176443299437335277 0.093862529892194568326 0.67872914113688032067;-1.290368380589799191 -0.19367102009247161298 1.7056439671441117056 -0.034356214271595610088 1.1568712968753145365 0.31675369602771275002 1.111433226305133859 -0.11488454125211799983 -0.9532901525271570975 -0.073221469670206859592 0.67078071803301098086 0.045921757978733976358 -0.28299796451725739432 1.837419147966231403 -0.31303725652255304235 1.404873166399992046 0.47125558509599413393 -1.4137739412754128931 -0.16296467791400570668 -0.77940457107344707222 0.8986035239735813418 -0.92346631337363771497 -0.090546073592277551145 1.0738037989177322551 -3.1662071652307326453 0.58720762869224185643 0.13232309345384324351 1.0256754823097826712;-1.4492759728330955049 -0.17631115868399077629 -0.48238226373407649961 0.75601007345861759301 -0.63902793633931886941 -0.94297302533529259172 -0.15210884627004092606 -1.7382391236081822239 -0.62204211661769504005 0.0028396545336575578639 0.18927918259707524062 0.13194234820687866794 0.18626270361774527329 -0.72391158380823306118 -0.39059197325631050957 0.16809136236467067671 -0.074738568088116796861 -0.35633127172614786904 0.14852630175422387726 0.74294489593811563477 -0.93819291638986324067 0.26988818598626723722 2.4722301974855342976 0.11688392009125556092 1.7155457505730047352 0.041972074972981755769 -0.47462463388724523972 0.7948462606445410028;1.8087700215378816893 -0.34977384484549228771 0.11562195956494630833 -1.0573053816309643249 0.27726150437585461717 0.30953501593620347254 -0.065101513029352270356 -0.32584752193030125378 -0.74038271590046023096 0.081661757189002953661 0.52650540745670815213 0.20454902613952122281 0.019822880664938775236 -1.1532638225513114349 0.39002947917758357121 -1.0489839713775177543 -0.51572793284421170057 0.37571628796839273701 0.15452546724402790868 0.45413153386637972186 0.30246977299951938178 0.43797918658839724015 -0.9897916665618048393 0.16204134256727018015 0.35705306659488755816 -0.056650228318464217192 -0.73504538718075540515 1.364678431010361459;0.86709767902070455925 0.42974316110204990871 -0.088530185306018790992 0.09148919434095408032 -0.14098706919533454673 0.52460837117616843095 -0.094704763249717632823 -0.41948074145636438104 -0.7697875491819515803 0.57838389998841677198 0.033401853398087127944 0.14670258735097349567 0.043348517013780646367 -0.2151615460684279113 0.079355639052681684054 -0.076340268179400858073 4.2671347913767442017e-05 0.78266112924513342453 -0.17712344703110724509 -0.1898649404960719711 -0.32170761131664865617 0.056253818927600757194 -0.020639191326249816533 0.29069826661489056585 -1.1425812782944388957 0.40630731100437578185 -0.091836636358565801319 0.41546765162434284857;0.34009622887653212508 -1.264484945738015842 0.43988648751261061332 -0.41074486966125561827 -0.0086414877725106108153 0.36026732984154513639 -0.035963281491515730615 -2.1079892810740412656 -0.66942432712791999361 0.027288384580838646876 0.46066707383474997384 -0.032618237137148745064 -0.43630860925739073375 0.14237329109851420972 -0.10508336679522177481 0.063310590258432108968 0.061330408274073086594 0.070793910572102408674 -0.0097209958347330115147 -0.10315433289706360531 0.10561166614227307514 0.39065395661315444054 -0.033298083646863943508 0.14949717229503720062 -0.96600884064415570851 0.17055863021540193514 0.25899414387629160483 -0.41688988352822542449];

% Layer 3
b3 = [-0.078751994427093671702;-0.082929972379051766773;0.080912372814605129645;0.042374188280362760917;-0.064086023193710719981;0.04065969953570818668;-0.081718982019368419101;-0.085689395083977687451;0.083771983469409241896;0.044260410220277518478;-0.066160299325171520457;0.043741795370991765068;-0.99999448464835749562;-1.0000131989467866411];
LW3_2 = [-0.10922569530381076586 0.030856142864769859485 -0.3667624178092287468 -0.19953726170648056204 0.071875936568950818395 -0.00476921449742522853 -0.00030925476309386551238 0.60974111716615331247 8.6875622030167104493e-05 -0.20480782799623495349 0.0075134018470458686229 0.040047124165949944674 -0.050691050594002216856 0.10519042630242537995;-0.14215992080511447027 0.065973684057821446736 -0.38680073897398231653 -0.25076839975986908726 -0.036181812303039656564 0.013254606147121457752 -0.00079634867350231641672 0.64357619908490037997 0.033958879449321507926 -0.21324341420050937912 0.022404874023440303488 0.053098692944007298833 0.029387272212432178492 0.079482856549840330551;0.12625555814424752055 -0.049014969966414211056 0.37712397474215797466 0.22602822145383316688 -0.016000670757405716094 0.0094335345841502805941 0.00056112476401740194604 -0.62723680062122799672 -0.017601651563805820883 0.20916976060512629254 -0.015213589697521980731 -0.046795921727898343034 0.0092835845341754461707 -0.091897374177102073012;0.29464971073390922029 -0.4118702530407268303 0.21888830809302359248 0.99336604118734672664 0.43090285385522825168 -0.048467903794433969678 0.00045903594105060191704 -0.35306801854216607328 -1.4593348793245086714 -0.037830959311222579766 -0.053122573003830900196 -0.11547430576854753048 -0.33995099318696542223 1.1372523701867749413;-0.32042746389724285905 0.018320597414331070418 -0.29920710837378816649 -0.055889820697606805433 -1.2426276180996542742 0.0097071434685794544261 -0.0005981355721362157556 0.54160676115466199754 -0.096182620505993299265 -0.1686408484048242673 0.00079685001762605706978 0.12225341841559722589 1.1495679787925101589 0.0065880748875484507199;-0.13139702102011521778 1.9794988608448069733 0.58918995773019600115 -0.20582619451541359079 -0.13836719320776877384 0.094032076886723839348 0.00019120124490326574542 -0.33027980029907666459 -0.83751231309511764422 -0.10438009428591561722 -0.20008348413108256736 0.049154032197895734801 0.052253769670552924209 -0.33054797108407979467;-0.1095649156403076252 0.031366571896072281689 -0.3649988957410414403 -0.19762799976156283921 0.070434657983156734318 -0.025873534082524667771 -0.00033662050482824142431 0.60705349880963155318 0.00089822467006101230219 -0.20379346036347972815 0.0074055439685634209812 0.040147680014559483652 -0.05185343244890137232 0.10559820150666532346;-0.14260957276775890201 0.066287016785512214989 -0.38497402500041633111 -0.24849881907329968156 -0.037171380056607306042 -0.041143337226052796585 -0.00082372086811024970883 0.64072479694314143917 0.034528562255481273779 -0.21218762125466636426 0.022249331893363512302 0.05323279514605924051 0.027865070582158601303 0.0800126641602399713;0.1266514815392828508 -0.049423060915457520115 0.37532753606684488012 0.22393202905119674595 -0.014794264323583126985 0.0075557276888820858532 0.00058848786989299883918 -0.62446408624024396516 -0.018287631214114884182 0.20813387127833790635 -0.015080895842101680465 -0.046913666153572328166 0.01063298629017746591 -0.092368559330518185124;0.29492850841399581574 -0.41139714158524942622 0.21831877764492849114 0.98986719338090667364 0.43033056786224260781 -0.037671600422423151544 0.00046131323676601492184 -0.35289787521780585644 -1.4577530820215813812 -0.037784645079792497646 -0.053178564875536439571 -0.11553497929696686375 -0.3390979891663913337 1.1355688545917519416;-0.32070565190525851529 0.018558035079724352623 -0.29828813398536341284 -0.055661436184533924498 -1.2402267267232629511 -0.019024806815552051248 -0.00062141685132329556492 0.54012929522973052165 -0.09531210362986794471 -0.16814379840025395207 0.0007109501035369396706 0.1223139204841581229 1.1461074026423518912 0.007678248617983882314;-0.13137093292838747383 1.9731548599962431823 0.58674853962400730367 -0.20605737637240256754 -0.13807299128473821126 0.038360432143301370633 0.00019257866593917627863 -0.3295657557929060899 -0.83498010069759109886 -0.10390553407828954924 -0.20030476664847610135 0.049149255042310380226 0.052177442896784442805 -0.32905877965663249407;-0.053564089914303683604 0.2084334433732407954 0.62417826242997298536 0.22224644111244223899 0.042784386758594430966 -0.031928360421785158263 0.0019188314388966574812 1.1157835550970522931 0.21231390756421791854 0.37217132463286739519 0.032961985074334065882 0.024822548993756379104 0.19542092788555529004 0.087735819996554581524;0.37403079028638941406 0.69128009675218948793 0.33045350567038939138 -0.0047831636946850898326 0.10263440295496022159 0.030548903127390687057 0.00023029572953627821998 0.48299798425378470679 0.92021376242974539661 0.17017740873958195347 0.02506856470482299315 -0.1390441224574434087 0.12995450957100718181 0.26691179734740866358];

% Output 1
y1_step1.ymin = -1;
y1_step1.gain = [24064.0560252138;22473.6684950174;11620.8435915486;893674.538173713;54821.2088001835;807616.133165018;23957.0368161794;22374.8029865842;11569.4516165617;892256.499461268;54688.8693985591;805158.701570429;21489.3521050186;2903008.67048894];
y1_step1.xoffset = [-3.82830299802939e-05;-4.0806178247076e-05;-9.30153368724826e-05;-1.16638261544163e-06;-1.70720380855479e-05;-1.28855281719205e-06;-3.8330189918499e-05;-4.08631473930954e-05;-9.36757031826848e-05;-1.17035034392575e-06;-1.70754177073304e-05;-1.29631350016027e-06;0;0];

% ===== SIMULATION ========

% Format Input Arguments
isCellX = iscell(X);
if ~isCellX
  X = {X};
end

% Dimensions
TS = size(X,2); % timesteps
if ~isempty(X)
  Q = size(X{1},2); % samples/series
else
  Q = 0;
end

% Allocate Outputs
Y = cell(1,TS);

% Time loop
for ts=1:TS

    % Input 1
    Xp1 = mapminmax_apply(X{1,ts},x1_step1);
    
    % Layer 1
    a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*Xp1);
    
    % Layer 2
    a2 = poslin_apply(repmat(b2,1,Q) + LW2_1*a1);
    
    % Layer 3
    a3 = repmat(b3,1,Q) + LW3_2*a2;
    
    % Output 1
    Y{1,ts} = mapminmax_reverse(a3,y1_step1);
end

% Final Delay States
Xf = cell(1,0);
Af = cell(3,0);

% Format Output Arguments
if ~isCellX
  Y = cell2mat(Y);
end
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
  y = bsxfun(@minus,x,settings.xoffset);
  y = bsxfun(@times,y,settings.gain);
  y = bsxfun(@plus,y,settings.ymin);
end

% Linear Positive Transfer Function
function a = poslin_apply(n,~)
  a = max(0,n);
  a(isnan(n)) = nan;
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
  a = 2 ./ (1 + exp(-2*n)) - 1;
end

% Map Minimum and Maximum Output Reverse-Processing Function
function x = mapminmax_reverse(y,settings)
  x = bsxfun(@minus,y,settings.ymin);
  x = bsxfun(@rdivide,x,settings.gain);
  x = bsxfun(@plus,x,settings.xoffset);
end
