require_relative "./analytics_helper"

class Analytics; end

describe User do
  it "loads fixtures" do
    Dir["analytics/*.json"].each do |path|
      values = JSON.parse(File.read(path))
      values.reject! { |k,v| ["uuid", "created_at", "updated_at"].include? k }
      values["playlists"] = Sequel.pg_json(values["playlists"])
      User.create(values)
    end

    assert_equal 3, User.count
    assert_equal 0, Track.count
  end

  it "processes playlist JSON" do
    User.all.each do |user|
      user.save_tracks!
    end
  end

  it "asserts database counts" do
    assert_equal 424, Track.count

    assert_equal 0,   Track.where(key: nil).count
    assert_equal 0,   Track.where(name: nil).count
    assert_equal 0,   Track.where(artist: nil).count
    assert_equal 0,   Track.where(album: nil).count
    assert_equal 0,   Track.where(duration: nil).count
    assert_equal 0,   Track.where(isrcs: nil).count
    assert_equal 424, Track.where(spotify_id: nil).count
    assert_equal 424, Track.where(spotify_isrc: nil).count


    assert_equal 0,   Track.db["SELECT * FROM tracks WHERE array_length(isrcs,1) = 0"].count
    assert_equal 399, Track.db["SELECT * FROM tracks WHERE array_length(isrcs,1) = 1"].count
    assert_equal 24,  Track.db["SELECT * FROM tracks WHERE array_length(isrcs,1) = 2"].count
    assert_equal 0,   Track.db["SELECT * FROM tracks WHERE array_length(isrcs,1) = 3"].count
    assert_equal 1,   Track.db["SELECT * FROM tracks WHERE array_length(isrcs,1) = 4"].count
  end

  it "uses isrcs to find and match spotify tracks" do
    Track.each do |track|
      track.match_spotify!
    end

    matched = Track.where("spotify_id IS NOT NULL").order(:key)
    assert_equal(
      ["t10003755", "t10003758", "t10003776", "t10003784", "t10003806", "t10003815", "t10003830", "t10003842", "t10003848", "t10003853", "t10003863", "t10003875", "t10003888", "t10003892", "t10003912", "t10003924", "t10003940", "t10003947", "t10015222", "t10856396", "t10856423", "t10873535", "t10873554", "t10873570", "t10935707", "t11250338", "t1153450", "t1161813", "t11662726", "t12044279", "t1207540", "t1218779", "t1232805", "t12342269", "t1235481", "t1235602", "t12386214", "t1264155", "t1268515", "t1268522", "t1273241", "t12760323", "t1280962", "t13037983", "t13038746", "t13038802", "t13038841", "t13038909", "t13038968", "t13039030", "t13039082", "t13039139", "t13039193", "t13039242", "t13039271", "t13039304", "t13039333", "t13039356", "t13039384", "t13039409", "t13039474", "t13039510", "t13039562", "t13049679", "t1312698", "t13210539", "t13552909", "t13742867", "t13980392", "t13980755", "t13988315", "t14123596", "t14128272", "t14128298", "t14313918", "t14313937", "t14313968", "t14314059", "t14889303", "t15073421", "t1511711", "t1555455", "t1555527", "t1555583", "t15593469", "t1567969", "t1568192", "t1568293", "t1568451", "t15739271", "t15857069", "t15969061", "t1636741", "t16497401", "t16497409", "t16497523", "t16497678", "t16497955", "t16498218", "t16498541", "t16498939", "t16499208", "t16499455", "t16499734", "t16499951", "t16840592", "t1694801", "t1694928", "t1695241", "t17095646", "t1750784", "t17547788", "t17547816", "t17547833", "t17547848", "t17547865", "t17547877", "t17547892", "t17547903", "t17547924", "t17547947", "t17547958", "t1853393", "t1867391", "t19289174", "t1961292", "t1982583", "t1984184", "t2015072", "t2015422", "t2062973", "t2081649", "t2086225", "t2101701", "t2109002", "t2109306", "t21183166", "t21229036", "t2145321", "t21981877", "t2213006", "t2213062", "t2213826", "t2221700", "t2222742", "t2234702", "t2249048", "t22627199", "t22627200", "t22627211", "t2276189", "t2296926", "t2314146", "t2323813", "t2393274", "t2458109", "t2483774", "t2483933", "t2484051", "t2484186", "t2484305", "t2484399", "t2484540", "t2484653", "t2484759", "t2484861", "t2485029", "t2485206", "t2485308", "t2485419", "t252747", "t2532985", "t2543931", "t2619189", "t2629843", "t2685879", "t27072345", "t2710309", "t2740539", "t27419640", "t2762381", "t2789787", "t2795672", "t27998965", "t2826130", "t2833583", "t2840783", "t28457574", "t2899086", "t2901574", "t29062248", "t2917864", "t29416322", "t2955329", "t29623503", "t30073445", "t3008152", "t301628", "t3057886", "t3058173", "t3059957", "t30763059", "t3102434", "t3116727", "t3128024", "t3128231", "t3128603", "t31400319", "t31505957", "t31506031", "t3160205", "t31961005", "t31979108", "t31979166", "t3199499", "t3199832", "t32326599", "t32807202", "t32961662", "t32961719", "t32991964", "t3329892", "t33382059", "t3385859", "t3385869", "t34766968", "t3483547", "t35040744", "t35041136", "t3514310", "t35264922", "t354768", "t354827", "t35956750", "t36251204", "t36551512", "t36552172", "t36736214", "t36736278", "t36759044", "t3705494", "t37373239", "t37383543", "t3781217", "t37836565", "t3815323", "t38215092", "t3837263", "t3895188", "t39130680", "t39130807", "t39131151", "t39134743", "t39224124", "t39468905", "t3983983", "t3984017", "t3984051", "t3984087", "t3984133", "t3984167", "t3984212", "t3984246", "t3984274", "t3984310", "t3984333", "t3984376", "t3984407", "t3985251", "t3985336", "t3995785", "t4008919", "t4023244", "t4064188", "t4064209", "t4064234", "t4064252", "t4064274", "t4064302", "t4064324", "t4064340", "t4064369", "t4064388", "t4064412", "t4064443", "t4064460", "t40678636", "t4105823", "t4298668", "t4365405", "t4536683", "t4539142", "t4539181", "t4539257", "t4539288", "t4539315", "t4539364", "t4539406", "t4539484", "t4539538", "t45415588", "t4544979", "t4569367", "t4569381", "t4569403", "t46524961", "t4685005", "t4742049", "t4837159", "t4936775", "t4947809", "t4947819", "t4947849", "t4947857", "t4998162", "t4998190", "t5132603", "t52431979", "t5351991", "t5384183", "t5397488", "t5592846", "t5679073", "t5719350", "t5819181", "t5883312", "t5904344", "t5990683", "t6107692", "t6151677", "t6164646", "t6531308", "t6791563", "t6858695", "t6896002", "t6986546", "t7116260", "t7130649", "t7130655", "t7130660", "t7130668", "t7130687", "t7134087", "t7148472", "t7169932", "t7224678", "t7224687", "t7224706", "t7235035", "t7235038", "t7310264", "t7321679", "t7323835", "t7325080", "t7325636", "t7325672", "t7325800", "t7340050", "t7349188", "t7349232", "t7354140", "t7354146", "t7354149", "t7367531", "t7369082", "t7369084", "t7450747", "t7450775", "t7651810", "t7707402", "t7707460", "t7759307", "t7759334", "t7759342", "t7856276", "t8081121", "t8147177", "t8254426", "t8305363", "t8916437", "t8922775", "t8992016", "t9192567", "t9196490", "t922785", "t9399991", "t9468493", "t9469533", "t9482185", "t9600386", "t9616341", "t9616371", "t9616400", "t9616445", "t9616464", "t9616493", "t9616516", "t9616551", "t9616576", "t9616589", "t9629508", "t9642948", "t9677236", "t9754916", "t9924697", "t9925079", "t9988770"],
      matched.map(:key)
    )

    unmatched = Track.where(spotify_id: nil).order(:key)
    assert_equal(
      ["t13039434", "t13974152", "t15026940", "t1511602", "t1539471", "t21223143", "t2281968", "t3361023", "t6323985", "t6397009", "t7158856", "t7324272", "t7707321", "t7949710", "t9290485", "t9912341", "t9923014"],
      unmatched.map(:key)
    )
  end

  xit "analyzes problem tracks" do
    keys = ["t13039434", "t13974152", "t15026940", "t1511602", "t1539471", "t21223143", "t2281968", "t3361023", "t6323985", "t6397009", "t7158856", "t7324272", "t7707321", "t7949710", "t9290485", "t9912341", "t9923014"]
    keys.each do |key|
      track = Track[key: key]
      puts Track[key: key].search_spotify2.inspect
    end
  end

  context "alternative matching strategies" do
  end
end

# describe Analytics do
#   context "processes entire dataset" do
#     it "turns User.playlist JSON collection into Track objects" do
#       isrcs = []

#       User.all.each do |user|
#         puts JSON.pretty_generate(user.values)
#         puts "\n\n\n\n\n"
#         isrcs += user.playlists_isrcs
#         # user.save_tracks!
#       end

#       assert_equal 444, isrcs.uniq.count
#     end

#     xit "matches and saves spotify_id for every Track" do
#       Track.all.each do |track|
#         track.match_spotify!
#       end
#     end
#   end

#   context "validates entire dataset" do
#     it "asserts database counts" do
#       assert_equal 3,   User.all.count
#       assert_equal 536, Track.all.count

#       assert_equal 0,   Track.where(rdio_key: nil).count
#       assert_equal 0,   Track.where(name: nil).count
#       assert_equal 0,   Track.where(artist: nil).count
#       assert_equal 0,   Track.where(album: nil).count
#       assert_equal 0,   Track.where(duration: nil).count
#       assert_equal 1,   Track.where(isrc: nil).count
#       assert_equal 29,  Track.where(spotify_id: nil).count
#     end
#   end

#   context "explores missing data" do
#     it "debugs missing rdio ISRC" do
#     end

#     it "debugs missing spotify_ids" do
#       Track.where(spotify_id: nil).each do |track|
#         # puts track.get_rdio.inspect
#         # r = track.search_spotify
#         # puts r.inspect
#         # track.match_spotify!
#         # track.get_rdio!
#         # puts track.match_by_total_edit_distance.inspect
#       end
#     end
#   end

#   context "compares matching strategies" do
#   end

#   context "tricky ISRCs" do
#     # {:isrc=>"GBZN81300014", :artist=>"CHVRCHES", :album=>"The Bones Of What You Believe (Special Edition)", :name=>"The Mother We Share", :duration=>190}
#     # {:isrc=>"DEAR41185973", :artist=>"Mantra Mindware", :album=>"Forgivness", :name=>"Isrc", :duration=>428}
#     # {:isrc=>"FRY680300093", :artist=>"Alain Chamfort", :album=>"Le Plaisir", :name=>"Titre 14 (indexé avec code ISRC)", :duration=>54}

#     # {:isrc=>"GBUM71300113", :artist=>"Haim", :album=>"Days Are Gone", :name=>"Falling", :duration=>257}
#     # {:isrc=>"USSM11300646", :artist=>"Haim", :album=>"Falling", :name=>"Falling", :duration=>258}
#     # {:isrc=>"USSM11300646", :artist=>"Haim", :album=>"Days Are Gone", :name=>"Falling", :duration=>257}

#     # {:isrc=>"GBCEL1300216", :artist=>"Washed Out", :album=>"Paracosm", :name=>"It All Feels Right", :duration=>245}
#     # {:isrc=>"USSUB1305502", :artist=>"Washed Out", :album=>"It All Feels Right", :name=>"It All Feels Right", :duration=>245}
#     # {:isrc=>"USSUB1305502", :artist=>"Washed Out", :album=>"Paracosm", :name=>"It All Feels Right", :duration=>245}

#     # {:isrc=>"USSM11304478", :artist=>"Haim", :album=>"Days Are Gone", :name=>"The Wire", :duration=>245}
#     # {:isrc=>"GBUM71304660", :artist=>"Haim", :album=>"Days Are Gone (Deluxe Edition)", :name=>"The Wire", :duration=>245}
#     # {:isrc=>"GBUM71304660", :artist=>"Haim", :album=>"Days Are Gone", :name=>"The Wire", :duration=>245}
#   end

# end
