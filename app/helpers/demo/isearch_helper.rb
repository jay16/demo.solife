﻿#encoding: utf-8
module Demo
  module ISearchHelper
    def isearch_content
    {
      :id   => "0",
      :type => "0",
      :desc => "",
      :name => "dir_0",
      :datas => [
        {
        :id   => "1",
        :name => "dir_1",
        :type => "0",
        :desc => "dir_1",
        :datas => [
          { :id   => "3",
            :name => "dir_3",
            :type => "0",
            :desc => "dir_3",
            :datas => [ 
              { :id => "4", name: "file_4", :type => "1", desc: "file-4", url: "url" },
              { :id => "5", name: "file_5", :type => "1", desc: "file-5", url: "url" },
              { :id => "6", name: "file_6", :type => "1", desc: "file-6", url: "url" },
              { :id => "7", name: "file_7", :type => "1", desc: "file-7", url: "url" },
              { :id => "8", name: "file_8", :type => "1", desc: "file-8", url: "url" }
            ]
          }]
        },
        {
          :id   => "9",
          :name => "file_9",
          :type => "1",
          :desc => "",
          :url  => ""
        },
        {
          :id   => "10",
          :name => "file_10",
          :type => "1",
          :desc => "",
          :url  => ""
        },
        {
          :id   => "11",
          :name => "file_11",
          :type => "1",
          :desc => "",
          :url  => ""
        },
        {
          :id   => "12",
          :name => "file_12",
          :type => "1",
          :desc => "",
          :url  => ""
        }
      ]
    }
    end

    def isearch_poetries
      poetry_list = <<-POETRY
     《行行重行行》之一
  　　行行重行行，与君生别离.   相去万余里，各在天一涯.   道路阻且长，会面安可知.   胡马依北风，越鸟巢南枝.   相去日已远，衣带日已缓.   浮云蔽白日，游子不顾反.   思君令人老，岁月忽已晚.   弃捐勿复道，努力加餐饭.
  　　《青青河畔草》之二
  　　青青河畔草,郁郁园中柳.   盈盈楼上女,皎皎当窗牖.   娥娥红粉妆,纤纤出素手.   昔为倡家女,今为荡子妇.   荡子行不归,空床难独守.
  　　《青青陵上柏》之三
  　　青青陵上柏,磊磊涧中石.   人生天地间,忽如远行客.   斗酒相娱乐,聊厚不为薄.   驱车策驽马,游戏宛与洛.   洛中何郁郁,冠带自相索.   长衢罗夹巷,王侯多第宅.   两宫遥相望,双阙百余尺.   极宴娱心意,戚戚何所迫
  　　《今日良宴会》之四
  　　今日良宴会,欢乐难具陈.   弹筝奋逸响,新声妙入神.   令德唱高言,识曲听其真.   齐心同所愿,含意俱未申.   人生寄一世,奄忽若飙尘.   何不策高足,先据要路津.   无为守穷贱,轗轲长苦辛.
  　　《西北有高楼》之五
  　　西北有高楼,上与浮云齐.   交疏结绮窗,阿阁三重阶.   上有弦歌声,音响一何悲!   谁能为此曲,无乃杞梁妻.   清商随风发,中曲正徘徊.   一弹再三叹,慷慨有余哀.   不惜歌者苦,但伤知音稀.   愿为双鸿鹄,奋翅起高飞.
  　　《涉江采芙蓉》之六
  　　涉江采芙蓉,兰泽多芳草.   采之欲遗谁,所思在远道.   还顾望旧乡,长路漫浩浩.   同心而离居,忧伤以终老.
  　　《明月皎夜光》之七
  　　明月皎夜光,促织鸣东壁.   玉衡指孟冬,众星何历历.   白露沾野草,时节忽复易.   秋蝉鸣树间,玄鸟逝安适.   昔我同门友,高举振六翮.   不念携手好,弃我如遗迹.   南箕北有斗,牵牛不负轭.   良无磐石固,虚名复何益
  　　《冉冉孤生竹》之八
  　　冉冉孤生竹,结根泰山阿.   与君为新婚,兔丝附女萝.   兔丝生有时,夫妇会有宜.   千里远结婚,悠悠隔山陂.   思君令人老,轩车来何迟!   伤彼蕙兰花,含英扬光辉.   过时而不采,将随秋草萎.   君亮执高节,贱妾亦何为!
  　　《庭中有奇树》之九
  　　庭中有奇树,绿叶发华滋.   攀条折其荣,将以遗所思.   馨香盈怀袖,路远莫致之.   此物何足贵,但感别经时.
  　　《迢迢牵牛星》之十
  　　迢迢牵牛星,皎皎河汉女.   纤纤擢素手,札札弄机杼.   终日不成章,泣涕零如雨.   河汉清且浅,相去复几许.   盈盈一水间,脉脉不得语.
  　　《回车驾言迈》之十一
  　　回车驾言迈,悠悠涉长道.   四顾何茫茫,东风摇百草.   所遇无故物,焉得不速老.   盛衰各有时,立身苦不早.   人生非金石,岂能长寿考   奄忽随物化,荣名以为宝.
  　　《东城高且长》之十二
  　　东城高且长,逶迤自相属.   回风动地起,秋草萋已绿.   四时更变化,岁暮一何速!   晨风怀苦心,蟋蟀伤局促.   荡涤放情志,何为自结束!   燕赵多佳人,美者颜如玉.   被服罗裳衣,当户理清曲.   音响一何悲!弦急知柱促.   驰情整巾带,沈吟聊踯躅.   思为双飞燕,衔泥巢君屋.
  　　《驱车上东门》之十三
  　　驱车上东门,遥望郭北墓.   白杨何萧萧,松柏夹广路.   下有陈死人,杳杳即长暮.   潜寐黄泉下,千载永不寤.   浩浩阴阳移,年命如朝露.   人生忽如寄,寿无金石固.   万岁更相送,贤圣莫能度.   服食求神仙,多为药所误.   不如饮美酒,被服纨与素.
  　　《去者日以疏》之十四
  　　去者日以疏,生者日已亲.   出郭门直视,但见丘与坟.   古墓犁为田,松柏摧为薪.   白杨多悲风,萧萧愁杀人!   思还故里闾,欲归道无因.
  　　《生年不满百》之十五
  　　生年不满百,常怀千岁忧.   昼短苦夜长,何不秉烛游!   为乐当及时,何能待来兹   愚者爱惜费,但为后世嗤.   仙人王子乔,难可与等期.
  　　《凛凛岁云暮》之十六
  　　凛凛岁云暮,蝼蛄夕鸣悲.   凉风率已厉,游子寒无衣.   锦衾遗洛浦,同袍与我违.   独宿累长夜,梦想见容辉.   良人惟古欢,枉驾惠前绥.   愿得常巧笑,携手同车归.   既来不须臾,又不处重闱.   亮无晨风翼,焉能凌风飞   眄睐以适意,引领遥相希.   徒倚怀感伤,垂涕沾双扉.
  　　《孟冬寒气至》之十七
  　　孟冬寒气至,北风何惨栗.   愁多知夜长,仰观众星列.   三五明月满,四五蟾兔缺.   客从远方来,遗我一书札.   上言长相思,下言久离别.   置书怀袖中,三岁字不灭.   一心抱区区,惧君不识察.   【注释】 三五:农历十五日. 四五:农历二十日. 三岁:三年.灭:消失. 区区:指相爱之情.
  　　《客从远方来》之十八
      客从远方来,遗我一端绮.   相去万余里,故人心尚尔.   文彩双鸳鸯,裁为合欢被.   着以长相思,缘以结不解.   以胶投漆中,谁能别离此
  　　《明月何皎皎》之十九
  　　明月何皎皎,照我罗床纬.   忧愁不能寐,揽衣起徘徊.   客行虽云乐,不如早旋归.   出户独彷徨,愁思当告谁!   引领还入房,泪下沾裳衣.
      POETRY
      array = []
      _lambda = lambda { |str| str.gsub(/(\s|#{12288.chr(Encoding::UTF_8)})+/, "\n").strip }
      poetry_list.split(/\n/).each_slice(2) do |a|
        array << a.map { |str| _lambda.call(str) }
      end
      return array
    end
  end
end

