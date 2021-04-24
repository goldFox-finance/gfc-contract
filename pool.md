t0 : 2 
t1 : 1

t2 : 3
t3 : 1
1*2/1 = 2


# 添加kswap 矿池
# OKB-USDT
ReInvestPool.deployed().then(function(c){r=c});
BscReInvestPool.at("0x15bbf51edb38f6b155211091a40610bdf05c9a1e").then(function(c){r=c});

ReInvestPool.deployed().then(function(c){r=c});

Common.at("0xc23e8ff4b6a7e6c29b849808d2b50f667fe3e527").then(function(c1){lp=c1});
Common.deployed().then(function(c1){c=c1});
c.addMiner(accounts[0])
c.mint(accounts[0],500000000000)

HecoReInvestPool.deployed().then(function(c){r=c});

// okb-usdt
r.add(6,20,"0xc23e8ff4b6a7e6c29b849808d2b50f667fe3e527",true,0,0,"0x97019205d81ed9302f349f18116fe3ddec37d384");

// ethk-usdt
r.add(1,20,"0xdf8010c2141042e0793dd0099241fba396d25209",true,0,0,"0x97019205d81ed9302f349f18116fe3ddec37d384")


// btck-usdt
r.add(0,20,"0x147608dfeeeb05fd149784b9b740f71babe8b69c",true,0,0,"0x97019205d81ed9302f349f18116fe3ddec37d384")

ReInvestPool.deployed().then(function(c){r=c});
//okb-usdt
Common.at("0x2170ed0880ac9a755fd29b2688956bd959f933f8").then(function(c1){lp=c1});
// 0xdf8010c2141042e0793dd0099241fba396d25209 ETH-USDT
Common.at("0xdf8010c2141042e0793dd0099241fba396d25209").then(function(c1){lp=c1});
// 0x147608dfeeeb05fd149784b9b740f71babe8b69c
Common.at("0x147608dfeeeb05fd149784b9b740f71babe8b69c").then(function(c1){lp=c1});

// husd-usdt 0xa1c7db0ed51d367e948021f95784594509f5b272
Common.at("0x55d398326f99059ff775485246999027b3197955").then(function(c1){lp=c1});

lp.balanceOf.call(accounts[0]).then(function(a){console.log(a.toString())})

lp.balanceOf.call("0x367B3E1356001604EcA34df5fe3419a74Fe0C419").then(function(a){console.log(a.toString())})

r.rewardLp(0,accounts[0]).then(function(a){console.log(a.toString())})

lp.approve(r.address,"1006038761521000000000000")
// 107739868141
r.GetPoolInfo(0)
r.GetURITInfo(0,accounts[0])
// 27043537816513
r.deposit(0,"3134473711591")
r.withdraw(0,"270435378165")
r.harvest(0)

r.kswap()

r.testwithdraw(0,"1416512235")
Common.at("0x97019205d81ed9302f349f18116fe3ddec37d384").then(function(c1){t=c1});
t.balanceOf.call(r.address).then(function(a){console.log(a.toString())})

r.pending(0,accounts[0]).then(function(a){console.log(a.toString())})

r.GetPoolInfo(0)
r.GetURITInfo(0,accounts[0])
// 复投

r.harvest(0)



// UK swap
UKSwapPool.deployed().then(function(c){r=c});

Common.at("0x18b62561574134230ec54ff04979163bd3a77b10").then(function(c1){lp=c1});
lp.balanceOf.call(accounts[0]).then(function(a){console.log(a.toString())})

r.deposit(0,"68569596743")
r.kswap()

r.withdraw(0,"69053982829")

r.harvest(0)


// SinglePool

SinglePool.deployed().then(function(c){s=c});


BscSinglePool.at("0x2fcd74230d75f1a7521dd7b4a72ccf7fad4904f8").then(function(c){s=c});

usdc
// s.add("0xf16c37c1beb143fb9debaafd548e381a97ba0693",20,"0x3e33590013b24bf21d4ccca3a965ea10e570d5b2",true,0,0,"0x74f22f000c98db39f2c433d7a3be459c2955873a");


ethk
// s.add("0xbef88205609a1470bde139bdb036f7a931c56c33",20,"0xdf950cecf33e64176ada5dd733e170a56d11478e",true,0,0,"0x74f22f000c98db39f2c433d7a3be459c2955873a");


btck
// s.add("0x7a33c4af2f7d7591fa8bcc3a87e27bbdcaee793c",20,"0x09973e7e3914eb5ba69c7c025f30ab9446e3e4e0",true,0,0,"0x74f22f000c98db39f2c433d7a3be459c2955873a");

Common.deployed().then(function(c1){c=c1});
c.balanceOf.call(r.address).then(function(a){console.log(a.toString())})

HecoSinglePool.deployed().then(function(c){s=c});

// usdc
Common.at("0xe579156f9decc4134b5e3a30a24ac46bb8b01281").then(function(c1){u=c1});


// husd 0x0298c2b32eae4da002a15f36fdf7615bea3da047
Common.at("0x55d398326f99059ff775485246999027b3197955").then(function(c1){u=c1});

975328720
54195040
// 270940960

u.balanceOf.call(accounts[0]).then(function(a){console.log(a.toString())})
s.rewardLp(1,accounts[0]).then(function(a){console.log(a.toString())})
u.approve(s.address,"4800000000000000000000000000")
163316541239600
// 100 USDC

s.deposit(0,"163316541239600") 
// 5000 USDC
s.harvest(1)
s.GetURITInfo(1,accounts[0])
s.withdraw(1,"8000")
s.testwithdraw(1)
s.harvest(1)
s.getProfit(0)
s.getSupply(0)

// 4307228402045
// 4307228402045
s.GetURITInfo(0,accounts[0])



// pool
// 0xc58069dce6ed21f75271c204a4971f57e5c2c3ba
Pool.deployed().then(function(c1){p=c1});
Pool.at("0xc11f81fDf4CC6A092De3497631C97F5D072E91F1").then(function(c1){p=c1});
// 0xc11f81fDf4CC6A092De3497631C97F5D072E91F1
p.add(10,"0xc58069dce6ed21f75271c204a4971f57e5c2c3ba",false,0,0,0,"0x0000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000")

p.add(10,"0xc3b9b4146fde102df21cdea7796461c088345d9a",false,0,0,0,"0x0000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000")


p.add(10,"0x3e33590013b24bf21d4ccca3a965ea10e570d5b2",false,0,0,0,"0xf16c37c1beb143fb9debaafd548e381a97ba0693","0x9115d528ce681d862d9ab28714f8bd8d150c1261")

p.add(10,"0xdf950cecf33e64176ada5dd733e170a56d11478e",false,0,0,0,"0xbef88205609a1470bde139bdb036f7a931c56c33","0x9115d528ce681d862d9ab28714f8bd8d150c1261")


// ------ lp
Common.at("0xc58069dce6ed21f75271c204a4971f57e5c2c3ba").then(function(c1){lp=c1});
lp.balanceOf.call(accounts[0]).then(function(a){console.log(a.toString())})
lp.approve(p.address,"10000")
p.deposit(0,"10000")
p.withdraw(0,"10000")

// -------- usdc
Common.at("0x3e33590013b24bf21d4ccca3a965ea10e570d5b2").then(function(c1){u=c1});
u.balanceOf.call(accounts[0]).then(function(a){console.log(a.toString())})
u.approve(p.address,"10000")
p.deposit(2,"10000")
p.withdraw(2,"10000")



p.set(2,17,true,0,0,300,100,"0xf16c37c1beb143fb9debaafd548e381a97ba0693","0x9115d528ce681d862d9ab28714f8bd8d150c1261")
