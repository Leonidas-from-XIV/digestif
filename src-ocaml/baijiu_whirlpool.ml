module By = Digestif_by
module Bi = Digestif_bi

module Int64 = struct
  include Int64

  let ( lsl ) = Int64.shift_left
  let ( lsr ) = Int64.shift_right
  let ( asr ) = Int64.shift_right_logical
  let ( lor ) = Int64.logor
  let ( land ) = Int64.logand
  let ( lxor ) = Int64.logxor
  let ( + ) = Int64.add
  let ror64 a n = (a asr n) lor (a lsl (64 - n))
  let rol64 a n = (a lsl n) lor (a asr (64 - n))
end

module type S = sig
  type kind = [`WHIRLPOOL]
  type ctx = {mutable size: int64; b: Bytes.t; h: int64 array}

  val init : unit -> ctx
  val unsafe_feed_bytes : ctx -> By.t -> int -> int -> unit
  val unsafe_feed_bigstring : ctx -> Bi.t -> int -> int -> unit
  val unsafe_get : ctx -> By.t
  val dup : ctx -> ctx
end

module Unsafe : S = struct
  type kind = [`WHIRLPOOL]
  type ctx = {mutable size: int64; b: Bytes.t; h: int64 array}

  let dup ctx = {size= ctx.size; b= By.copy ctx.b; h= Array.copy ctx.h}

  let init () =
    let b = By.make 64 '\x00' in
    {size= 0L; b; h= Array.make 8 Int64.zero}

  let k =
    [| [| 0x18186018c07830d8L; 0x23238c2305af4626L; 0xc6c63fc67ef991b8L
        ; 0xe8e887e8136fcdfbL; 0x878726874ca113cbL; 0xb8b8dab8a9626d11L
        ; 0x0101040108050209L; 0x4f4f214f426e9e0dL; 0x3636d836adee6c9bL
        ; 0xa6a6a2a6590451ffL; 0xd2d26fd2debdb90cL; 0xf5f5f3f5fb06f70eL
        ; 0x7979f979ef80f296L; 0x6f6fa16f5fcede30L; 0x91917e91fcef3f6dL
        ; 0x52525552aa07a4f8L; 0x60609d6027fdc047L; 0xbcbccabc89766535L
        ; 0x9b9b569baccd2b37L; 0x8e8e028e048c018aL; 0xa3a3b6a371155bd2L
        ; 0x0c0c300c603c186cL; 0x7b7bf17bff8af684L; 0x3535d435b5e16a80L
        ; 0x1d1d741de8693af5L; 0xe0e0a7e05347ddb3L; 0xd7d77bd7f6acb321L
        ; 0xc2c22fc25eed999cL; 0x2e2eb82e6d965c43L; 0x4b4b314b627a9629L
        ; 0xfefedffea321e15dL; 0x575741578216aed5L; 0x15155415a8412abdL
        ; 0x7777c1779fb6eee8L; 0x3737dc37a5eb6e92L; 0xe5e5b3e57b56d79eL
        ; 0x9f9f469f8cd92313L; 0xf0f0e7f0d317fd23L; 0x4a4a354a6a7f9420L
        ; 0xdada4fda9e95a944L; 0x58587d58fa25b0a2L; 0xc9c903c906ca8fcfL
        ; 0x2929a429558d527cL; 0x0a0a280a5022145aL; 0xb1b1feb1e14f7f50L
        ; 0xa0a0baa0691a5dc9L; 0x6b6bb16b7fdad614L; 0x85852e855cab17d9L
        ; 0xbdbdcebd8173673cL; 0x5d5d695dd234ba8fL; 0x1010401080502090L
        ; 0xf4f4f7f4f303f507L; 0xcbcb0bcb16c08bddL; 0x3e3ef83eedc67cd3L
        ; 0x0505140528110a2dL; 0x676781671fe6ce78L; 0xe4e4b7e47353d597L
        ; 0x27279c2725bb4e02L; 0x4141194132588273L; 0x8b8b168b2c9d0ba7L
        ; 0xa7a7a6a7510153f6L; 0x7d7de97dcf94fab2L; 0x95956e95dcfb3749L
        ; 0xd8d847d88e9fad56L; 0xfbfbcbfb8b30eb70L; 0xeeee9fee2371c1cdL
        ; 0x7c7ced7cc791f8bbL; 0x6666856617e3cc71L; 0xdddd53dda68ea77bL
        ; 0x17175c17b84b2eafL; 0x4747014702468e45L; 0x9e9e429e84dc211aL
        ; 0xcaca0fca1ec589d4L; 0x2d2db42d75995a58L; 0xbfbfc6bf9179632eL
        ; 0x07071c07381b0e3fL; 0xadad8ead012347acL; 0x5a5a755aea2fb4b0L
        ; 0x838336836cb51befL; 0x3333cc3385ff66b6L; 0x636391633ff2c65cL
        ; 0x02020802100a0412L; 0xaaaa92aa39384993L; 0x7171d971afa8e2deL
        ; 0xc8c807c80ecf8dc6L; 0x19196419c87d32d1L; 0x494939497270923bL
        ; 0xd9d943d9869aaf5fL; 0xf2f2eff2c31df931L; 0xe3e3abe34b48dba8L
        ; 0x5b5b715be22ab6b9L; 0x88881a8834920dbcL; 0x9a9a529aa4c8293eL
        ; 0x262698262dbe4c0bL; 0x3232c8328dfa64bfL; 0xb0b0fab0e94a7d59L
        ; 0xe9e983e91b6acff2L; 0x0f0f3c0f78331e77L; 0xd5d573d5e6a6b733L
        ; 0x80803a8074ba1df4L; 0xbebec2be997c6127L; 0xcdcd13cd26de87ebL
        ; 0x3434d034bde46889L; 0x48483d487a759032L; 0xffffdbffab24e354L
        ; 0x7a7af57af78ff48dL; 0x90907a90f4ea3d64L; 0x5f5f615fc23ebe9dL
        ; 0x202080201da0403dL; 0x6868bd6867d5d00fL; 0x1a1a681ad07234caL
        ; 0xaeae82ae192c41b7L; 0xb4b4eab4c95e757dL; 0x54544d549a19a8ceL
        ; 0x93937693ece53b7fL; 0x222288220daa442fL; 0x64648d6407e9c863L
        ; 0xf1f1e3f1db12ff2aL; 0x7373d173bfa2e6ccL; 0x12124812905a2482L
        ; 0x40401d403a5d807aL; 0x0808200840281048L; 0xc3c32bc356e89b95L
        ; 0xecec97ec337bc5dfL; 0xdbdb4bdb9690ab4dL; 0xa1a1bea1611f5fc0L
        ; 0x8d8d0e8d1c830791L; 0x3d3df43df5c97ac8L; 0x97976697ccf1335bL
        ; 0x0000000000000000L; 0xcfcf1bcf36d483f9L; 0x2b2bac2b4587566eL
        ; 0x7676c57697b3ece1L; 0x8282328264b019e6L; 0xd6d67fd6fea9b128L
        ; 0x1b1b6c1bd87736c3L; 0xb5b5eeb5c15b7774L; 0xafaf86af112943beL
        ; 0x6a6ab56a77dfd41dL; 0x50505d50ba0da0eaL; 0x45450945124c8a57L
        ; 0xf3f3ebf3cb18fb38L; 0x3030c0309df060adL; 0xefef9bef2b74c3c4L
        ; 0x3f3ffc3fe5c37edaL; 0x55554955921caac7L; 0xa2a2b2a2791059dbL
        ; 0xeaea8fea0365c9e9L; 0x656589650fecca6aL; 0xbabad2bab9686903L
        ; 0x2f2fbc2f65935e4aL; 0xc0c027c04ee79d8eL; 0xdede5fdebe81a160L
        ; 0x1c1c701ce06c38fcL; 0xfdfdd3fdbb2ee746L; 0x4d4d294d52649a1fL
        ; 0x92927292e4e03976L; 0x7575c9758fbceafaL; 0x06061806301e0c36L
        ; 0x8a8a128a249809aeL; 0xb2b2f2b2f940794bL; 0xe6e6bfe66359d185L
        ; 0x0e0e380e70361c7eL; 0x1f1f7c1ff8633ee7L; 0x6262956237f7c455L
        ; 0xd4d477d4eea3b53aL; 0xa8a89aa829324d81L; 0x96966296c4f43152L
        ; 0xf9f9c3f99b3aef62L; 0xc5c533c566f697a3L; 0x2525942535b14a10L
        ; 0x59597959f220b2abL; 0x84842a8454ae15d0L; 0x7272d572b7a7e4c5L
        ; 0x3939e439d5dd72ecL; 0x4c4c2d4c5a619816L; 0x5e5e655eca3bbc94L
        ; 0x7878fd78e785f09fL; 0x3838e038ddd870e5L; 0x8c8c0a8c14860598L
        ; 0xd1d163d1c6b2bf17L; 0xa5a5aea5410b57e4L; 0xe2e2afe2434dd9a1L
        ; 0x616199612ff8c24eL; 0xb3b3f6b3f1457b42L; 0x2121842115a54234L
        ; 0x9c9c4a9c94d62508L; 0x1e1e781ef0663ceeL; 0x4343114322528661L
        ; 0xc7c73bc776fc93b1L; 0xfcfcd7fcb32be54fL; 0x0404100420140824L
        ; 0x51515951b208a2e3L; 0x99995e99bcc72f25L; 0x6d6da96d4fc4da22L
        ; 0x0d0d340d68391a65L; 0xfafacffa8335e979L; 0xdfdf5bdfb684a369L
        ; 0x7e7ee57ed79bfca9L; 0x242490243db44819L; 0x3b3bec3bc5d776feL
        ; 0xabab96ab313d4b9aL; 0xcece1fce3ed181f0L; 0x1111441188552299L
        ; 0x8f8f068f0c890383L; 0x4e4e254e4a6b9c04L; 0xb7b7e6b7d1517366L
        ; 0xebeb8beb0b60cbe0L; 0x3c3cf03cfdcc78c1L; 0x81813e817cbf1ffdL
        ; 0x94946a94d4fe3540L; 0xf7f7fbf7eb0cf31cL; 0xb9b9deb9a1676f18L
        ; 0x13134c13985f268bL; 0x2c2cb02c7d9c5851L; 0xd3d36bd3d6b8bb05L
        ; 0xe7e7bbe76b5cd38cL; 0x6e6ea56e57cbdc39L; 0xc4c437c46ef395aaL
        ; 0x03030c03180f061bL; 0x565645568a13acdcL; 0x44440d441a49885eL
        ; 0x7f7fe17fdf9efea0L; 0xa9a99ea921374f88L; 0x2a2aa82a4d825467L
        ; 0xbbbbd6bbb16d6b0aL; 0xc1c123c146e29f87L; 0x53535153a202a6f1L
        ; 0xdcdc57dcae8ba572L; 0x0b0b2c0b58271653L; 0x9d9d4e9d9cd32701L
        ; 0x6c6cad6c47c1d82bL; 0x3131c43195f562a4L; 0x7474cd7487b9e8f3L
        ; 0xf6f6fff6e309f115L; 0x464605460a438c4cL; 0xacac8aac092645a5L
        ; 0x89891e893c970fb5L; 0x14145014a04428b4L; 0xe1e1a3e15b42dfbaL
        ; 0x16165816b04e2ca6L; 0x3a3ae83acdd274f7L; 0x6969b9696fd0d206L
        ; 0x09092409482d1241L; 0x7070dd70a7ade0d7L; 0xb6b6e2b6d954716fL
        ; 0xd0d067d0ceb7bd1eL; 0xeded93ed3b7ec7d6L; 0xcccc17cc2edb85e2L
        ; 0x424215422a578468L; 0x98985a98b4c22d2cL; 0xa4a4aaa4490e55edL
        ; 0x2828a0285d885075L; 0x5c5c6d5cda31b886L; 0xf8f8c7f8933fed6bL
        ; 0x8686228644a411c2L |]
     ; [| 0xd818186018c07830L; 0x2623238c2305af46L; 0xb8c6c63fc67ef991L
        ; 0xfbe8e887e8136fcdL; 0xcb878726874ca113L; 0x11b8b8dab8a9626dL
        ; 0x0901010401080502L; 0x0d4f4f214f426e9eL; 0x9b3636d836adee6cL
        ; 0xffa6a6a2a6590451L; 0x0cd2d26fd2debdb9L; 0x0ef5f5f3f5fb06f7L
        ; 0x967979f979ef80f2L; 0x306f6fa16f5fcedeL; 0x6d91917e91fcef3fL
        ; 0xf852525552aa07a4L; 0x4760609d6027fdc0L; 0x35bcbccabc897665L
        ; 0x379b9b569baccd2bL; 0x8a8e8e028e048c01L; 0xd2a3a3b6a371155bL
        ; 0x6c0c0c300c603c18L; 0x847b7bf17bff8af6L; 0x803535d435b5e16aL
        ; 0xf51d1d741de8693aL; 0xb3e0e0a7e05347ddL; 0x21d7d77bd7f6acb3L
        ; 0x9cc2c22fc25eed99L; 0x432e2eb82e6d965cL; 0x294b4b314b627a96L
        ; 0x5dfefedffea321e1L; 0xd5575741578216aeL; 0xbd15155415a8412aL
        ; 0xe87777c1779fb6eeL; 0x923737dc37a5eb6eL; 0x9ee5e5b3e57b56d7L
        ; 0x139f9f469f8cd923L; 0x23f0f0e7f0d317fdL; 0x204a4a354a6a7f94L
        ; 0x44dada4fda9e95a9L; 0xa258587d58fa25b0L; 0xcfc9c903c906ca8fL
        ; 0x7c2929a429558d52L; 0x5a0a0a280a502214L; 0x50b1b1feb1e14f7fL
        ; 0xc9a0a0baa0691a5dL; 0x146b6bb16b7fdad6L; 0xd985852e855cab17L
        ; 0x3cbdbdcebd817367L; 0x8f5d5d695dd234baL; 0x9010104010805020L
        ; 0x07f4f4f7f4f303f5L; 0xddcbcb0bcb16c08bL; 0xd33e3ef83eedc67cL
        ; 0x2d0505140528110aL; 0x78676781671fe6ceL; 0x97e4e4b7e47353d5L
        ; 0x0227279c2725bb4eL; 0x7341411941325882L; 0xa78b8b168b2c9d0bL
        ; 0xf6a7a7a6a7510153L; 0xb27d7de97dcf94faL; 0x4995956e95dcfb37L
        ; 0x56d8d847d88e9fadL; 0x70fbfbcbfb8b30ebL; 0xcdeeee9fee2371c1L
        ; 0xbb7c7ced7cc791f8L; 0x716666856617e3ccL; 0x7bdddd53dda68ea7L
        ; 0xaf17175c17b84b2eL; 0x454747014702468eL; 0x1a9e9e429e84dc21L
        ; 0xd4caca0fca1ec589L; 0x582d2db42d75995aL; 0x2ebfbfc6bf917963L
        ; 0x3f07071c07381b0eL; 0xacadad8ead012347L; 0xb05a5a755aea2fb4L
        ; 0xef838336836cb51bL; 0xb63333cc3385ff66L; 0x5c636391633ff2c6L
        ; 0x1202020802100a04L; 0x93aaaa92aa393849L; 0xde7171d971afa8e2L
        ; 0xc6c8c807c80ecf8dL; 0xd119196419c87d32L; 0x3b49493949727092L
        ; 0x5fd9d943d9869aafL; 0x31f2f2eff2c31df9L; 0xa8e3e3abe34b48dbL
        ; 0xb95b5b715be22ab6L; 0xbc88881a8834920dL; 0x3e9a9a529aa4c829L
        ; 0x0b262698262dbe4cL; 0xbf3232c8328dfa64L; 0x59b0b0fab0e94a7dL
        ; 0xf2e9e983e91b6acfL; 0x770f0f3c0f78331eL; 0x33d5d573d5e6a6b7L
        ; 0xf480803a8074ba1dL; 0x27bebec2be997c61L; 0xebcdcd13cd26de87L
        ; 0x893434d034bde468L; 0x3248483d487a7590L; 0x54ffffdbffab24e3L
        ; 0x8d7a7af57af78ff4L; 0x6490907a90f4ea3dL; 0x9d5f5f615fc23ebeL
        ; 0x3d202080201da040L; 0x0f6868bd6867d5d0L; 0xca1a1a681ad07234L
        ; 0xb7aeae82ae192c41L; 0x7db4b4eab4c95e75L; 0xce54544d549a19a8L
        ; 0x7f93937693ece53bL; 0x2f222288220daa44L; 0x6364648d6407e9c8L
        ; 0x2af1f1e3f1db12ffL; 0xcc7373d173bfa2e6L; 0x8212124812905a24L
        ; 0x7a40401d403a5d80L; 0x4808082008402810L; 0x95c3c32bc356e89bL
        ; 0xdfecec97ec337bc5L; 0x4ddbdb4bdb9690abL; 0xc0a1a1bea1611f5fL
        ; 0x918d8d0e8d1c8307L; 0xc83d3df43df5c97aL; 0x5b97976697ccf133L
        ; 0x0000000000000000L; 0xf9cfcf1bcf36d483L; 0x6e2b2bac2b458756L
        ; 0xe17676c57697b3ecL; 0xe68282328264b019L; 0x28d6d67fd6fea9b1L
        ; 0xc31b1b6c1bd87736L; 0x74b5b5eeb5c15b77L; 0xbeafaf86af112943L
        ; 0x1d6a6ab56a77dfd4L; 0xea50505d50ba0da0L; 0x5745450945124c8aL
        ; 0x38f3f3ebf3cb18fbL; 0xad3030c0309df060L; 0xc4efef9bef2b74c3L
        ; 0xda3f3ffc3fe5c37eL; 0xc755554955921caaL; 0xdba2a2b2a2791059L
        ; 0xe9eaea8fea0365c9L; 0x6a656589650feccaL; 0x03babad2bab96869L
        ; 0x4a2f2fbc2f65935eL; 0x8ec0c027c04ee79dL; 0x60dede5fdebe81a1L
        ; 0xfc1c1c701ce06c38L; 0x46fdfdd3fdbb2ee7L; 0x1f4d4d294d52649aL
        ; 0x7692927292e4e039L; 0xfa7575c9758fbceaL; 0x3606061806301e0cL
        ; 0xae8a8a128a249809L; 0x4bb2b2f2b2f94079L; 0x85e6e6bfe66359d1L
        ; 0x7e0e0e380e70361cL; 0xe71f1f7c1ff8633eL; 0x556262956237f7c4L
        ; 0x3ad4d477d4eea3b5L; 0x81a8a89aa829324dL; 0x5296966296c4f431L
        ; 0x62f9f9c3f99b3aefL; 0xa3c5c533c566f697L; 0x102525942535b14aL
        ; 0xab59597959f220b2L; 0xd084842a8454ae15L; 0xc57272d572b7a7e4L
        ; 0xec3939e439d5dd72L; 0x164c4c2d4c5a6198L; 0x945e5e655eca3bbcL
        ; 0x9f7878fd78e785f0L; 0xe53838e038ddd870L; 0x988c8c0a8c148605L
        ; 0x17d1d163d1c6b2bfL; 0xe4a5a5aea5410b57L; 0xa1e2e2afe2434dd9L
        ; 0x4e616199612ff8c2L; 0x42b3b3f6b3f1457bL; 0x342121842115a542L
        ; 0x089c9c4a9c94d625L; 0xee1e1e781ef0663cL; 0x6143431143225286L
        ; 0xb1c7c73bc776fc93L; 0x4ffcfcd7fcb32be5L; 0x2404041004201408L
        ; 0xe351515951b208a2L; 0x2599995e99bcc72fL; 0x226d6da96d4fc4daL
        ; 0x650d0d340d68391aL; 0x79fafacffa8335e9L; 0x69dfdf5bdfb684a3L
        ; 0xa97e7ee57ed79bfcL; 0x19242490243db448L; 0xfe3b3bec3bc5d776L
        ; 0x9aabab96ab313d4bL; 0xf0cece1fce3ed181L; 0x9911114411885522L
        ; 0x838f8f068f0c8903L; 0x044e4e254e4a6b9cL; 0x66b7b7e6b7d15173L
        ; 0xe0ebeb8beb0b60cbL; 0xc13c3cf03cfdcc78L; 0xfd81813e817cbf1fL
        ; 0x4094946a94d4fe35L; 0x1cf7f7fbf7eb0cf3L; 0x18b9b9deb9a1676fL
        ; 0x8b13134c13985f26L; 0x512c2cb02c7d9c58L; 0x05d3d36bd3d6b8bbL
        ; 0x8ce7e7bbe76b5cd3L; 0x396e6ea56e57cbdcL; 0xaac4c437c46ef395L
        ; 0x1b03030c03180f06L; 0xdc565645568a13acL; 0x5e44440d441a4988L
        ; 0xa07f7fe17fdf9efeL; 0x88a9a99ea921374fL; 0x672a2aa82a4d8254L
        ; 0x0abbbbd6bbb16d6bL; 0x87c1c123c146e29fL; 0xf153535153a202a6L
        ; 0x72dcdc57dcae8ba5L; 0x530b0b2c0b582716L; 0x019d9d4e9d9cd327L
        ; 0x2b6c6cad6c47c1d8L; 0xa43131c43195f562L; 0xf37474cd7487b9e8L
        ; 0x15f6f6fff6e309f1L; 0x4c464605460a438cL; 0xa5acac8aac092645L
        ; 0xb589891e893c970fL; 0xb414145014a04428L; 0xbae1e1a3e15b42dfL
        ; 0xa616165816b04e2cL; 0xf73a3ae83acdd274L; 0x066969b9696fd0d2L
        ; 0x4109092409482d12L; 0xd77070dd70a7ade0L; 0x6fb6b6e2b6d95471L
        ; 0x1ed0d067d0ceb7bdL; 0xd6eded93ed3b7ec7L; 0xe2cccc17cc2edb85L
        ; 0x68424215422a5784L; 0x2c98985a98b4c22dL; 0xeda4a4aaa4490e55L
        ; 0x752828a0285d8850L; 0x865c5c6d5cda31b8L; 0x6bf8f8c7f8933fedL
        ; 0xc28686228644a411L |]
     ; [| 0x30d818186018c078L; 0x462623238c2305afL; 0x91b8c6c63fc67ef9L
        ; 0xcdfbe8e887e8136fL; 0x13cb878726874ca1L; 0x6d11b8b8dab8a962L
        ; 0x0209010104010805L; 0x9e0d4f4f214f426eL; 0x6c9b3636d836adeeL
        ; 0x51ffa6a6a2a65904L; 0xb90cd2d26fd2debdL; 0xf70ef5f5f3f5fb06L
        ; 0xf2967979f979ef80L; 0xde306f6fa16f5fceL; 0x3f6d91917e91fcefL
        ; 0xa4f852525552aa07L; 0xc04760609d6027fdL; 0x6535bcbccabc8976L
        ; 0x2b379b9b569baccdL; 0x018a8e8e028e048cL; 0x5bd2a3a3b6a37115L
        ; 0x186c0c0c300c603cL; 0xf6847b7bf17bff8aL; 0x6a803535d435b5e1L
        ; 0x3af51d1d741de869L; 0xddb3e0e0a7e05347L; 0xb321d7d77bd7f6acL
        ; 0x999cc2c22fc25eedL; 0x5c432e2eb82e6d96L; 0x96294b4b314b627aL
        ; 0xe15dfefedffea321L; 0xaed5575741578216L; 0x2abd15155415a841L
        ; 0xeee87777c1779fb6L; 0x6e923737dc37a5ebL; 0xd79ee5e5b3e57b56L
        ; 0x23139f9f469f8cd9L; 0xfd23f0f0e7f0d317L; 0x94204a4a354a6a7fL
        ; 0xa944dada4fda9e95L; 0xb0a258587d58fa25L; 0x8fcfc9c903c906caL
        ; 0x527c2929a429558dL; 0x145a0a0a280a5022L; 0x7f50b1b1feb1e14fL
        ; 0x5dc9a0a0baa0691aL; 0xd6146b6bb16b7fdaL; 0x17d985852e855cabL
        ; 0x673cbdbdcebd8173L; 0xba8f5d5d695dd234L; 0x2090101040108050L
        ; 0xf507f4f4f7f4f303L; 0x8bddcbcb0bcb16c0L; 0x7cd33e3ef83eedc6L
        ; 0x0a2d050514052811L; 0xce78676781671fe6L; 0xd597e4e4b7e47353L
        ; 0x4e0227279c2725bbL; 0x8273414119413258L; 0x0ba78b8b168b2c9dL
        ; 0x53f6a7a7a6a75101L; 0xfab27d7de97dcf94L; 0x374995956e95dcfbL
        ; 0xad56d8d847d88e9fL; 0xeb70fbfbcbfb8b30L; 0xc1cdeeee9fee2371L
        ; 0xf8bb7c7ced7cc791L; 0xcc716666856617e3L; 0xa77bdddd53dda68eL
        ; 0x2eaf17175c17b84bL; 0x8e45474701470246L; 0x211a9e9e429e84dcL
        ; 0x89d4caca0fca1ec5L; 0x5a582d2db42d7599L; 0x632ebfbfc6bf9179L
        ; 0x0e3f07071c07381bL; 0x47acadad8ead0123L; 0xb4b05a5a755aea2fL
        ; 0x1bef838336836cb5L; 0x66b63333cc3385ffL; 0xc65c636391633ff2L
        ; 0x041202020802100aL; 0x4993aaaa92aa3938L; 0xe2de7171d971afa8L
        ; 0x8dc6c8c807c80ecfL; 0x32d119196419c87dL; 0x923b494939497270L
        ; 0xaf5fd9d943d9869aL; 0xf931f2f2eff2c31dL; 0xdba8e3e3abe34b48L
        ; 0xb6b95b5b715be22aL; 0x0dbc88881a883492L; 0x293e9a9a529aa4c8L
        ; 0x4c0b262698262dbeL; 0x64bf3232c8328dfaL; 0x7d59b0b0fab0e94aL
        ; 0xcff2e9e983e91b6aL; 0x1e770f0f3c0f7833L; 0xb733d5d573d5e6a6L
        ; 0x1df480803a8074baL; 0x6127bebec2be997cL; 0x87ebcdcd13cd26deL
        ; 0x68893434d034bde4L; 0x903248483d487a75L; 0xe354ffffdbffab24L
        ; 0xf48d7a7af57af78fL; 0x3d6490907a90f4eaL; 0xbe9d5f5f615fc23eL
        ; 0x403d202080201da0L; 0xd00f6868bd6867d5L; 0x34ca1a1a681ad072L
        ; 0x41b7aeae82ae192cL; 0x757db4b4eab4c95eL; 0xa8ce54544d549a19L
        ; 0x3b7f93937693ece5L; 0x442f222288220daaL; 0xc86364648d6407e9L
        ; 0xff2af1f1e3f1db12L; 0xe6cc7373d173bfa2L; 0x248212124812905aL
        ; 0x807a40401d403a5dL; 0x1048080820084028L; 0x9b95c3c32bc356e8L
        ; 0xc5dfecec97ec337bL; 0xab4ddbdb4bdb9690L; 0x5fc0a1a1bea1611fL
        ; 0x07918d8d0e8d1c83L; 0x7ac83d3df43df5c9L; 0x335b97976697ccf1L
        ; 0x0000000000000000L; 0x83f9cfcf1bcf36d4L; 0x566e2b2bac2b4587L
        ; 0xece17676c57697b3L; 0x19e68282328264b0L; 0xb128d6d67fd6fea9L
        ; 0x36c31b1b6c1bd877L; 0x7774b5b5eeb5c15bL; 0x43beafaf86af1129L
        ; 0xd41d6a6ab56a77dfL; 0xa0ea50505d50ba0dL; 0x8a5745450945124cL
        ; 0xfb38f3f3ebf3cb18L; 0x60ad3030c0309df0L; 0xc3c4efef9bef2b74L
        ; 0x7eda3f3ffc3fe5c3L; 0xaac755554955921cL; 0x59dba2a2b2a27910L
        ; 0xc9e9eaea8fea0365L; 0xca6a656589650fecL; 0x6903babad2bab968L
        ; 0x5e4a2f2fbc2f6593L; 0x9d8ec0c027c04ee7L; 0xa160dede5fdebe81L
        ; 0x38fc1c1c701ce06cL; 0xe746fdfdd3fdbb2eL; 0x9a1f4d4d294d5264L
        ; 0x397692927292e4e0L; 0xeafa7575c9758fbcL; 0x0c3606061806301eL
        ; 0x09ae8a8a128a2498L; 0x794bb2b2f2b2f940L; 0xd185e6e6bfe66359L
        ; 0x1c7e0e0e380e7036L; 0x3ee71f1f7c1ff863L; 0xc4556262956237f7L
        ; 0xb53ad4d477d4eea3L; 0x4d81a8a89aa82932L; 0x315296966296c4f4L
        ; 0xef62f9f9c3f99b3aL; 0x97a3c5c533c566f6L; 0x4a102525942535b1L
        ; 0xb2ab59597959f220L; 0x15d084842a8454aeL; 0xe4c57272d572b7a7L
        ; 0x72ec3939e439d5ddL; 0x98164c4c2d4c5a61L; 0xbc945e5e655eca3bL
        ; 0xf09f7878fd78e785L; 0x70e53838e038ddd8L; 0x05988c8c0a8c1486L
        ; 0xbf17d1d163d1c6b2L; 0x57e4a5a5aea5410bL; 0xd9a1e2e2afe2434dL
        ; 0xc24e616199612ff8L; 0x7b42b3b3f6b3f145L; 0x42342121842115a5L
        ; 0x25089c9c4a9c94d6L; 0x3cee1e1e781ef066L; 0x8661434311432252L
        ; 0x93b1c7c73bc776fcL; 0xe54ffcfcd7fcb32bL; 0x0824040410042014L
        ; 0xa2e351515951b208L; 0x2f2599995e99bcc7L; 0xda226d6da96d4fc4L
        ; 0x1a650d0d340d6839L; 0xe979fafacffa8335L; 0xa369dfdf5bdfb684L
        ; 0xfca97e7ee57ed79bL; 0x4819242490243db4L; 0x76fe3b3bec3bc5d7L
        ; 0x4b9aabab96ab313dL; 0x81f0cece1fce3ed1L; 0x2299111144118855L
        ; 0x03838f8f068f0c89L; 0x9c044e4e254e4a6bL; 0x7366b7b7e6b7d151L
        ; 0xcbe0ebeb8beb0b60L; 0x78c13c3cf03cfdccL; 0x1ffd81813e817cbfL
        ; 0x354094946a94d4feL; 0xf31cf7f7fbf7eb0cL; 0x6f18b9b9deb9a167L
        ; 0x268b13134c13985fL; 0x58512c2cb02c7d9cL; 0xbb05d3d36bd3d6b8L
        ; 0xd38ce7e7bbe76b5cL; 0xdc396e6ea56e57cbL; 0x95aac4c437c46ef3L
        ; 0x061b03030c03180fL; 0xacdc565645568a13L; 0x885e44440d441a49L
        ; 0xfea07f7fe17fdf9eL; 0x4f88a9a99ea92137L; 0x54672a2aa82a4d82L
        ; 0x6b0abbbbd6bbb16dL; 0x9f87c1c123c146e2L; 0xa6f153535153a202L
        ; 0xa572dcdc57dcae8bL; 0x16530b0b2c0b5827L; 0x27019d9d4e9d9cd3L
        ; 0xd82b6c6cad6c47c1L; 0x62a43131c43195f5L; 0xe8f37474cd7487b9L
        ; 0xf115f6f6fff6e309L; 0x8c4c464605460a43L; 0x45a5acac8aac0926L
        ; 0x0fb589891e893c97L; 0x28b414145014a044L; 0xdfbae1e1a3e15b42L
        ; 0x2ca616165816b04eL; 0x74f73a3ae83acdd2L; 0xd2066969b9696fd0L
        ; 0x124109092409482dL; 0xe0d77070dd70a7adL; 0x716fb6b6e2b6d954L
        ; 0xbd1ed0d067d0ceb7L; 0xc7d6eded93ed3b7eL; 0x85e2cccc17cc2edbL
        ; 0x8468424215422a57L; 0x2d2c98985a98b4c2L; 0x55eda4a4aaa4490eL
        ; 0x50752828a0285d88L; 0xb8865c5c6d5cda31L; 0xed6bf8f8c7f8933fL
        ; 0x11c28686228644a4L |]
     ; [| 0x7830d818186018c0L; 0xaf462623238c2305L; 0xf991b8c6c63fc67eL
        ; 0x6fcdfbe8e887e813L; 0xa113cb878726874cL; 0x626d11b8b8dab8a9L
        ; 0x0502090101040108L; 0x6e9e0d4f4f214f42L; 0xee6c9b3636d836adL
        ; 0x0451ffa6a6a2a659L; 0xbdb90cd2d26fd2deL; 0x06f70ef5f5f3f5fbL
        ; 0x80f2967979f979efL; 0xcede306f6fa16f5fL; 0xef3f6d91917e91fcL
        ; 0x07a4f852525552aaL; 0xfdc04760609d6027L; 0x766535bcbccabc89L
        ; 0xcd2b379b9b569bacL; 0x8c018a8e8e028e04L; 0x155bd2a3a3b6a371L
        ; 0x3c186c0c0c300c60L; 0x8af6847b7bf17bffL; 0xe16a803535d435b5L
        ; 0x693af51d1d741de8L; 0x47ddb3e0e0a7e053L; 0xacb321d7d77bd7f6L
        ; 0xed999cc2c22fc25eL; 0x965c432e2eb82e6dL; 0x7a96294b4b314b62L
        ; 0x21e15dfefedffea3L; 0x16aed55757415782L; 0x412abd15155415a8L
        ; 0xb6eee87777c1779fL; 0xeb6e923737dc37a5L; 0x56d79ee5e5b3e57bL
        ; 0xd923139f9f469f8cL; 0x17fd23f0f0e7f0d3L; 0x7f94204a4a354a6aL
        ; 0x95a944dada4fda9eL; 0x25b0a258587d58faL; 0xca8fcfc9c903c906L
        ; 0x8d527c2929a42955L; 0x22145a0a0a280a50L; 0x4f7f50b1b1feb1e1L
        ; 0x1a5dc9a0a0baa069L; 0xdad6146b6bb16b7fL; 0xab17d985852e855cL
        ; 0x73673cbdbdcebd81L; 0x34ba8f5d5d695dd2L; 0x5020901010401080L
        ; 0x03f507f4f4f7f4f3L; 0xc08bddcbcb0bcb16L; 0xc67cd33e3ef83eedL
        ; 0x110a2d0505140528L; 0xe6ce78676781671fL; 0x53d597e4e4b7e473L
        ; 0xbb4e0227279c2725L; 0x5882734141194132L; 0x9d0ba78b8b168b2cL
        ; 0x0153f6a7a7a6a751L; 0x94fab27d7de97dcfL; 0xfb374995956e95dcL
        ; 0x9fad56d8d847d88eL; 0x30eb70fbfbcbfb8bL; 0x71c1cdeeee9fee23L
        ; 0x91f8bb7c7ced7cc7L; 0xe3cc716666856617L; 0x8ea77bdddd53dda6L
        ; 0x4b2eaf17175c17b8L; 0x468e454747014702L; 0xdc211a9e9e429e84L
        ; 0xc589d4caca0fca1eL; 0x995a582d2db42d75L; 0x79632ebfbfc6bf91L
        ; 0x1b0e3f07071c0738L; 0x2347acadad8ead01L; 0x2fb4b05a5a755aeaL
        ; 0xb51bef838336836cL; 0xff66b63333cc3385L; 0xf2c65c636391633fL
        ; 0x0a04120202080210L; 0x384993aaaa92aa39L; 0xa8e2de7171d971afL
        ; 0xcf8dc6c8c807c80eL; 0x7d32d119196419c8L; 0x70923b4949394972L
        ; 0x9aaf5fd9d943d986L; 0x1df931f2f2eff2c3L; 0x48dba8e3e3abe34bL
        ; 0x2ab6b95b5b715be2L; 0x920dbc88881a8834L; 0xc8293e9a9a529aa4L
        ; 0xbe4c0b262698262dL; 0xfa64bf3232c8328dL; 0x4a7d59b0b0fab0e9L
        ; 0x6acff2e9e983e91bL; 0x331e770f0f3c0f78L; 0xa6b733d5d573d5e6L
        ; 0xba1df480803a8074L; 0x7c6127bebec2be99L; 0xde87ebcdcd13cd26L
        ; 0xe468893434d034bdL; 0x75903248483d487aL; 0x24e354ffffdbffabL
        ; 0x8ff48d7a7af57af7L; 0xea3d6490907a90f4L; 0x3ebe9d5f5f615fc2L
        ; 0xa0403d202080201dL; 0xd5d00f6868bd6867L; 0x7234ca1a1a681ad0L
        ; 0x2c41b7aeae82ae19L; 0x5e757db4b4eab4c9L; 0x19a8ce54544d549aL
        ; 0xe53b7f93937693ecL; 0xaa442f222288220dL; 0xe9c86364648d6407L
        ; 0x12ff2af1f1e3f1dbL; 0xa2e6cc7373d173bfL; 0x5a24821212481290L
        ; 0x5d807a40401d403aL; 0x2810480808200840L; 0xe89b95c3c32bc356L
        ; 0x7bc5dfecec97ec33L; 0x90ab4ddbdb4bdb96L; 0x1f5fc0a1a1bea161L
        ; 0x8307918d8d0e8d1cL; 0xc97ac83d3df43df5L; 0xf1335b97976697ccL
        ; 0x0000000000000000L; 0xd483f9cfcf1bcf36L; 0x87566e2b2bac2b45L
        ; 0xb3ece17676c57697L; 0xb019e68282328264L; 0xa9b128d6d67fd6feL
        ; 0x7736c31b1b6c1bd8L; 0x5b7774b5b5eeb5c1L; 0x2943beafaf86af11L
        ; 0xdfd41d6a6ab56a77L; 0x0da0ea50505d50baL; 0x4c8a574545094512L
        ; 0x18fb38f3f3ebf3cbL; 0xf060ad3030c0309dL; 0x74c3c4efef9bef2bL
        ; 0xc37eda3f3ffc3fe5L; 0x1caac75555495592L; 0x1059dba2a2b2a279L
        ; 0x65c9e9eaea8fea03L; 0xecca6a656589650fL; 0x686903babad2bab9L
        ; 0x935e4a2f2fbc2f65L; 0xe79d8ec0c027c04eL; 0x81a160dede5fdebeL
        ; 0x6c38fc1c1c701ce0L; 0x2ee746fdfdd3fdbbL; 0x649a1f4d4d294d52L
        ; 0xe0397692927292e4L; 0xbceafa7575c9758fL; 0x1e0c360606180630L
        ; 0x9809ae8a8a128a24L; 0x40794bb2b2f2b2f9L; 0x59d185e6e6bfe663L
        ; 0x361c7e0e0e380e70L; 0x633ee71f1f7c1ff8L; 0xf7c4556262956237L
        ; 0xa3b53ad4d477d4eeL; 0x324d81a8a89aa829L; 0xf4315296966296c4L
        ; 0x3aef62f9f9c3f99bL; 0xf697a3c5c533c566L; 0xb14a102525942535L
        ; 0x20b2ab59597959f2L; 0xae15d084842a8454L; 0xa7e4c57272d572b7L
        ; 0xdd72ec3939e439d5L; 0x6198164c4c2d4c5aL; 0x3bbc945e5e655ecaL
        ; 0x85f09f7878fd78e7L; 0xd870e53838e038ddL; 0x8605988c8c0a8c14L
        ; 0xb2bf17d1d163d1c6L; 0x0b57e4a5a5aea541L; 0x4dd9a1e2e2afe243L
        ; 0xf8c24e616199612fL; 0x457b42b3b3f6b3f1L; 0xa542342121842115L
        ; 0xd625089c9c4a9c94L; 0x663cee1e1e781ef0L; 0x5286614343114322L
        ; 0xfc93b1c7c73bc776L; 0x2be54ffcfcd7fcb3L; 0x1408240404100420L
        ; 0x08a2e351515951b2L; 0xc72f2599995e99bcL; 0xc4da226d6da96d4fL
        ; 0x391a650d0d340d68L; 0x35e979fafacffa83L; 0x84a369dfdf5bdfb6L
        ; 0x9bfca97e7ee57ed7L; 0xb44819242490243dL; 0xd776fe3b3bec3bc5L
        ; 0x3d4b9aabab96ab31L; 0xd181f0cece1fce3eL; 0x5522991111441188L
        ; 0x8903838f8f068f0cL; 0x6b9c044e4e254e4aL; 0x517366b7b7e6b7d1L
        ; 0x60cbe0ebeb8beb0bL; 0xcc78c13c3cf03cfdL; 0xbf1ffd81813e817cL
        ; 0xfe354094946a94d4L; 0x0cf31cf7f7fbf7ebL; 0x676f18b9b9deb9a1L
        ; 0x5f268b13134c1398L; 0x9c58512c2cb02c7dL; 0xb8bb05d3d36bd3d6L
        ; 0x5cd38ce7e7bbe76bL; 0xcbdc396e6ea56e57L; 0xf395aac4c437c46eL
        ; 0x0f061b03030c0318L; 0x13acdc565645568aL; 0x49885e44440d441aL
        ; 0x9efea07f7fe17fdfL; 0x374f88a9a99ea921L; 0x8254672a2aa82a4dL
        ; 0x6d6b0abbbbd6bbb1L; 0xe29f87c1c123c146L; 0x02a6f153535153a2L
        ; 0x8ba572dcdc57dcaeL; 0x2716530b0b2c0b58L; 0xd327019d9d4e9d9cL
        ; 0xc1d82b6c6cad6c47L; 0xf562a43131c43195L; 0xb9e8f37474cd7487L
        ; 0x09f115f6f6fff6e3L; 0x438c4c464605460aL; 0x2645a5acac8aac09L
        ; 0x970fb589891e893cL; 0x4428b414145014a0L; 0x42dfbae1e1a3e15bL
        ; 0x4e2ca616165816b0L; 0xd274f73a3ae83acdL; 0xd0d2066969b9696fL
        ; 0x2d12410909240948L; 0xade0d77070dd70a7L; 0x54716fb6b6e2b6d9L
        ; 0xb7bd1ed0d067d0ceL; 0x7ec7d6eded93ed3bL; 0xdb85e2cccc17cc2eL
        ; 0x578468424215422aL; 0xc22d2c98985a98b4L; 0x0e55eda4a4aaa449L
        ; 0x8850752828a0285dL; 0x31b8865c5c6d5cdaL; 0x3fed6bf8f8c7f893L
        ; 0xa411c28686228644L |]
     ; [| 0xc07830d818186018L; 0x05af462623238c23L; 0x7ef991b8c6c63fc6L
        ; 0x136fcdfbe8e887e8L; 0x4ca113cb87872687L; 0xa9626d11b8b8dab8L
        ; 0x0805020901010401L; 0x426e9e0d4f4f214fL; 0xadee6c9b3636d836L
        ; 0x590451ffa6a6a2a6L; 0xdebdb90cd2d26fd2L; 0xfb06f70ef5f5f3f5L
        ; 0xef80f2967979f979L; 0x5fcede306f6fa16fL; 0xfcef3f6d91917e91L
        ; 0xaa07a4f852525552L; 0x27fdc04760609d60L; 0x89766535bcbccabcL
        ; 0xaccd2b379b9b569bL; 0x048c018a8e8e028eL; 0x71155bd2a3a3b6a3L
        ; 0x603c186c0c0c300cL; 0xff8af6847b7bf17bL; 0xb5e16a803535d435L
        ; 0xe8693af51d1d741dL; 0x5347ddb3e0e0a7e0L; 0xf6acb321d7d77bd7L
        ; 0x5eed999cc2c22fc2L; 0x6d965c432e2eb82eL; 0x627a96294b4b314bL
        ; 0xa321e15dfefedffeL; 0x8216aed557574157L; 0xa8412abd15155415L
        ; 0x9fb6eee87777c177L; 0xa5eb6e923737dc37L; 0x7b56d79ee5e5b3e5L
        ; 0x8cd923139f9f469fL; 0xd317fd23f0f0e7f0L; 0x6a7f94204a4a354aL
        ; 0x9e95a944dada4fdaL; 0xfa25b0a258587d58L; 0x06ca8fcfc9c903c9L
        ; 0x558d527c2929a429L; 0x5022145a0a0a280aL; 0xe14f7f50b1b1feb1L
        ; 0x691a5dc9a0a0baa0L; 0x7fdad6146b6bb16bL; 0x5cab17d985852e85L
        ; 0x8173673cbdbdcebdL; 0xd234ba8f5d5d695dL; 0x8050209010104010L
        ; 0xf303f507f4f4f7f4L; 0x16c08bddcbcb0bcbL; 0xedc67cd33e3ef83eL
        ; 0x28110a2d05051405L; 0x1fe6ce7867678167L; 0x7353d597e4e4b7e4L
        ; 0x25bb4e0227279c27L; 0x3258827341411941L; 0x2c9d0ba78b8b168bL
        ; 0x510153f6a7a7a6a7L; 0xcf94fab27d7de97dL; 0xdcfb374995956e95L
        ; 0x8e9fad56d8d847d8L; 0x8b30eb70fbfbcbfbL; 0x2371c1cdeeee9feeL
        ; 0xc791f8bb7c7ced7cL; 0x17e3cc7166668566L; 0xa68ea77bdddd53ddL
        ; 0xb84b2eaf17175c17L; 0x02468e4547470147L; 0x84dc211a9e9e429eL
        ; 0x1ec589d4caca0fcaL; 0x75995a582d2db42dL; 0x9179632ebfbfc6bfL
        ; 0x381b0e3f07071c07L; 0x012347acadad8eadL; 0xea2fb4b05a5a755aL
        ; 0x6cb51bef83833683L; 0x85ff66b63333cc33L; 0x3ff2c65c63639163L
        ; 0x100a041202020802L; 0x39384993aaaa92aaL; 0xafa8e2de7171d971L
        ; 0x0ecf8dc6c8c807c8L; 0xc87d32d119196419L; 0x7270923b49493949L
        ; 0x869aaf5fd9d943d9L; 0xc31df931f2f2eff2L; 0x4b48dba8e3e3abe3L
        ; 0xe22ab6b95b5b715bL; 0x34920dbc88881a88L; 0xa4c8293e9a9a529aL
        ; 0x2dbe4c0b26269826L; 0x8dfa64bf3232c832L; 0xe94a7d59b0b0fab0L
        ; 0x1b6acff2e9e983e9L; 0x78331e770f0f3c0fL; 0xe6a6b733d5d573d5L
        ; 0x74ba1df480803a80L; 0x997c6127bebec2beL; 0x26de87ebcdcd13cdL
        ; 0xbde468893434d034L; 0x7a75903248483d48L; 0xab24e354ffffdbffL
        ; 0xf78ff48d7a7af57aL; 0xf4ea3d6490907a90L; 0xc23ebe9d5f5f615fL
        ; 0x1da0403d20208020L; 0x67d5d00f6868bd68L; 0xd07234ca1a1a681aL
        ; 0x192c41b7aeae82aeL; 0xc95e757db4b4eab4L; 0x9a19a8ce54544d54L
        ; 0xece53b7f93937693L; 0x0daa442f22228822L; 0x07e9c86364648d64L
        ; 0xdb12ff2af1f1e3f1L; 0xbfa2e6cc7373d173L; 0x905a248212124812L
        ; 0x3a5d807a40401d40L; 0x4028104808082008L; 0x56e89b95c3c32bc3L
        ; 0x337bc5dfecec97ecL; 0x9690ab4ddbdb4bdbL; 0x611f5fc0a1a1bea1L
        ; 0x1c8307918d8d0e8dL; 0xf5c97ac83d3df43dL; 0xccf1335b97976697L
        ; 0x0000000000000000L; 0x36d483f9cfcf1bcfL; 0x4587566e2b2bac2bL
        ; 0x97b3ece17676c576L; 0x64b019e682823282L; 0xfea9b128d6d67fd6L
        ; 0xd87736c31b1b6c1bL; 0xc15b7774b5b5eeb5L; 0x112943beafaf86afL
        ; 0x77dfd41d6a6ab56aL; 0xba0da0ea50505d50L; 0x124c8a5745450945L
        ; 0xcb18fb38f3f3ebf3L; 0x9df060ad3030c030L; 0x2b74c3c4efef9befL
        ; 0xe5c37eda3f3ffc3fL; 0x921caac755554955L; 0x791059dba2a2b2a2L
        ; 0x0365c9e9eaea8feaL; 0x0fecca6a65658965L; 0xb9686903babad2baL
        ; 0x65935e4a2f2fbc2fL; 0x4ee79d8ec0c027c0L; 0xbe81a160dede5fdeL
        ; 0xe06c38fc1c1c701cL; 0xbb2ee746fdfdd3fdL; 0x52649a1f4d4d294dL
        ; 0xe4e0397692927292L; 0x8fbceafa7575c975L; 0x301e0c3606061806L
        ; 0x249809ae8a8a128aL; 0xf940794bb2b2f2b2L; 0x6359d185e6e6bfe6L
        ; 0x70361c7e0e0e380eL; 0xf8633ee71f1f7c1fL; 0x37f7c45562629562L
        ; 0xeea3b53ad4d477d4L; 0x29324d81a8a89aa8L; 0xc4f4315296966296L
        ; 0x9b3aef62f9f9c3f9L; 0x66f697a3c5c533c5L; 0x35b14a1025259425L
        ; 0xf220b2ab59597959L; 0x54ae15d084842a84L; 0xb7a7e4c57272d572L
        ; 0xd5dd72ec3939e439L; 0x5a6198164c4c2d4cL; 0xca3bbc945e5e655eL
        ; 0xe785f09f7878fd78L; 0xddd870e53838e038L; 0x148605988c8c0a8cL
        ; 0xc6b2bf17d1d163d1L; 0x410b57e4a5a5aea5L; 0x434dd9a1e2e2afe2L
        ; 0x2ff8c24e61619961L; 0xf1457b42b3b3f6b3L; 0x15a5423421218421L
        ; 0x94d625089c9c4a9cL; 0xf0663cee1e1e781eL; 0x2252866143431143L
        ; 0x76fc93b1c7c73bc7L; 0xb32be54ffcfcd7fcL; 0x2014082404041004L
        ; 0xb208a2e351515951L; 0xbcc72f2599995e99L; 0x4fc4da226d6da96dL
        ; 0x68391a650d0d340dL; 0x8335e979fafacffaL; 0xb684a369dfdf5bdfL
        ; 0xd79bfca97e7ee57eL; 0x3db4481924249024L; 0xc5d776fe3b3bec3bL
        ; 0x313d4b9aabab96abL; 0x3ed181f0cece1fceL; 0x8855229911114411L
        ; 0x0c8903838f8f068fL; 0x4a6b9c044e4e254eL; 0xd1517366b7b7e6b7L
        ; 0x0b60cbe0ebeb8bebL; 0xfdcc78c13c3cf03cL; 0x7cbf1ffd81813e81L
        ; 0xd4fe354094946a94L; 0xeb0cf31cf7f7fbf7L; 0xa1676f18b9b9deb9L
        ; 0x985f268b13134c13L; 0x7d9c58512c2cb02cL; 0xd6b8bb05d3d36bd3L
        ; 0x6b5cd38ce7e7bbe7L; 0x57cbdc396e6ea56eL; 0x6ef395aac4c437c4L
        ; 0x180f061b03030c03L; 0x8a13acdc56564556L; 0x1a49885e44440d44L
        ; 0xdf9efea07f7fe17fL; 0x21374f88a9a99ea9L; 0x4d8254672a2aa82aL
        ; 0xb16d6b0abbbbd6bbL; 0x46e29f87c1c123c1L; 0xa202a6f153535153L
        ; 0xae8ba572dcdc57dcL; 0x582716530b0b2c0bL; 0x9cd327019d9d4e9dL
        ; 0x47c1d82b6c6cad6cL; 0x95f562a43131c431L; 0x87b9e8f37474cd74L
        ; 0xe309f115f6f6fff6L; 0x0a438c4c46460546L; 0x092645a5acac8aacL
        ; 0x3c970fb589891e89L; 0xa04428b414145014L; 0x5b42dfbae1e1a3e1L
        ; 0xb04e2ca616165816L; 0xcdd274f73a3ae83aL; 0x6fd0d2066969b969L
        ; 0x482d124109092409L; 0xa7ade0d77070dd70L; 0xd954716fb6b6e2b6L
        ; 0xceb7bd1ed0d067d0L; 0x3b7ec7d6eded93edL; 0x2edb85e2cccc17ccL
        ; 0x2a57846842421542L; 0xb4c22d2c98985a98L; 0x490e55eda4a4aaa4L
        ; 0x5d8850752828a028L; 0xda31b8865c5c6d5cL; 0x933fed6bf8f8c7f8L
        ; 0x44a411c286862286L |]
     ; [| 0x18c07830d8181860L; 0x2305af462623238cL; 0xc67ef991b8c6c63fL
        ; 0xe8136fcdfbe8e887L; 0x874ca113cb878726L; 0xb8a9626d11b8b8daL
        ; 0x0108050209010104L; 0x4f426e9e0d4f4f21L; 0x36adee6c9b3636d8L
        ; 0xa6590451ffa6a6a2L; 0xd2debdb90cd2d26fL; 0xf5fb06f70ef5f5f3L
        ; 0x79ef80f2967979f9L; 0x6f5fcede306f6fa1L; 0x91fcef3f6d91917eL
        ; 0x52aa07a4f8525255L; 0x6027fdc04760609dL; 0xbc89766535bcbccaL
        ; 0x9baccd2b379b9b56L; 0x8e048c018a8e8e02L; 0xa371155bd2a3a3b6L
        ; 0x0c603c186c0c0c30L; 0x7bff8af6847b7bf1L; 0x35b5e16a803535d4L
        ; 0x1de8693af51d1d74L; 0xe05347ddb3e0e0a7L; 0xd7f6acb321d7d77bL
        ; 0xc25eed999cc2c22fL; 0x2e6d965c432e2eb8L; 0x4b627a96294b4b31L
        ; 0xfea321e15dfefedfL; 0x578216aed5575741L; 0x15a8412abd151554L
        ; 0x779fb6eee87777c1L; 0x37a5eb6e923737dcL; 0xe57b56d79ee5e5b3L
        ; 0x9f8cd923139f9f46L; 0xf0d317fd23f0f0e7L; 0x4a6a7f94204a4a35L
        ; 0xda9e95a944dada4fL; 0x58fa25b0a258587dL; 0xc906ca8fcfc9c903L
        ; 0x29558d527c2929a4L; 0x0a5022145a0a0a28L; 0xb1e14f7f50b1b1feL
        ; 0xa0691a5dc9a0a0baL; 0x6b7fdad6146b6bb1L; 0x855cab17d985852eL
        ; 0xbd8173673cbdbdceL; 0x5dd234ba8f5d5d69L; 0x1080502090101040L
        ; 0xf4f303f507f4f4f7L; 0xcb16c08bddcbcb0bL; 0x3eedc67cd33e3ef8L
        ; 0x0528110a2d050514L; 0x671fe6ce78676781L; 0xe47353d597e4e4b7L
        ; 0x2725bb4e0227279cL; 0x4132588273414119L; 0x8b2c9d0ba78b8b16L
        ; 0xa7510153f6a7a7a6L; 0x7dcf94fab27d7de9L; 0x95dcfb374995956eL
        ; 0xd88e9fad56d8d847L; 0xfb8b30eb70fbfbcbL; 0xee2371c1cdeeee9fL
        ; 0x7cc791f8bb7c7cedL; 0x6617e3cc71666685L; 0xdda68ea77bdddd53L
        ; 0x17b84b2eaf17175cL; 0x4702468e45474701L; 0x9e84dc211a9e9e42L
        ; 0xca1ec589d4caca0fL; 0x2d75995a582d2db4L; 0xbf9179632ebfbfc6L
        ; 0x07381b0e3f07071cL; 0xad012347acadad8eL; 0x5aea2fb4b05a5a75L
        ; 0x836cb51bef838336L; 0x3385ff66b63333ccL; 0x633ff2c65c636391L
        ; 0x02100a0412020208L; 0xaa39384993aaaa92L; 0x71afa8e2de7171d9L
        ; 0xc80ecf8dc6c8c807L; 0x19c87d32d1191964L; 0x497270923b494939L
        ; 0xd9869aaf5fd9d943L; 0xf2c31df931f2f2efL; 0xe34b48dba8e3e3abL
        ; 0x5be22ab6b95b5b71L; 0x8834920dbc88881aL; 0x9aa4c8293e9a9a52L
        ; 0x262dbe4c0b262698L; 0x328dfa64bf3232c8L; 0xb0e94a7d59b0b0faL
        ; 0xe91b6acff2e9e983L; 0x0f78331e770f0f3cL; 0xd5e6a6b733d5d573L
        ; 0x8074ba1df480803aL; 0xbe997c6127bebec2L; 0xcd26de87ebcdcd13L
        ; 0x34bde468893434d0L; 0x487a75903248483dL; 0xffab24e354ffffdbL
        ; 0x7af78ff48d7a7af5L; 0x90f4ea3d6490907aL; 0x5fc23ebe9d5f5f61L
        ; 0x201da0403d202080L; 0x6867d5d00f6868bdL; 0x1ad07234ca1a1a68L
        ; 0xae192c41b7aeae82L; 0xb4c95e757db4b4eaL; 0x549a19a8ce54544dL
        ; 0x93ece53b7f939376L; 0x220daa442f222288L; 0x6407e9c86364648dL
        ; 0xf1db12ff2af1f1e3L; 0x73bfa2e6cc7373d1L; 0x12905a2482121248L
        ; 0x403a5d807a40401dL; 0x0840281048080820L; 0xc356e89b95c3c32bL
        ; 0xec337bc5dfecec97L; 0xdb9690ab4ddbdb4bL; 0xa1611f5fc0a1a1beL
        ; 0x8d1c8307918d8d0eL; 0x3df5c97ac83d3df4L; 0x97ccf1335b979766L
        ; 0x0000000000000000L; 0xcf36d483f9cfcf1bL; 0x2b4587566e2b2bacL
        ; 0x7697b3ece17676c5L; 0x8264b019e6828232L; 0xd6fea9b128d6d67fL
        ; 0x1bd87736c31b1b6cL; 0xb5c15b7774b5b5eeL; 0xaf112943beafaf86L
        ; 0x6a77dfd41d6a6ab5L; 0x50ba0da0ea50505dL; 0x45124c8a57454509L
        ; 0xf3cb18fb38f3f3ebL; 0x309df060ad3030c0L; 0xef2b74c3c4efef9bL
        ; 0x3fe5c37eda3f3ffcL; 0x55921caac7555549L; 0xa2791059dba2a2b2L
        ; 0xea0365c9e9eaea8fL; 0x650fecca6a656589L; 0xbab9686903babad2L
        ; 0x2f65935e4a2f2fbcL; 0xc04ee79d8ec0c027L; 0xdebe81a160dede5fL
        ; 0x1ce06c38fc1c1c70L; 0xfdbb2ee746fdfdd3L; 0x4d52649a1f4d4d29L
        ; 0x92e4e03976929272L; 0x758fbceafa7575c9L; 0x06301e0c36060618L
        ; 0x8a249809ae8a8a12L; 0xb2f940794bb2b2f2L; 0xe66359d185e6e6bfL
        ; 0x0e70361c7e0e0e38L; 0x1ff8633ee71f1f7cL; 0x6237f7c455626295L
        ; 0xd4eea3b53ad4d477L; 0xa829324d81a8a89aL; 0x96c4f43152969662L
        ; 0xf99b3aef62f9f9c3L; 0xc566f697a3c5c533L; 0x2535b14a10252594L
        ; 0x59f220b2ab595979L; 0x8454ae15d084842aL; 0x72b7a7e4c57272d5L
        ; 0x39d5dd72ec3939e4L; 0x4c5a6198164c4c2dL; 0x5eca3bbc945e5e65L
        ; 0x78e785f09f7878fdL; 0x38ddd870e53838e0L; 0x8c148605988c8c0aL
        ; 0xd1c6b2bf17d1d163L; 0xa5410b57e4a5a5aeL; 0xe2434dd9a1e2e2afL
        ; 0x612ff8c24e616199L; 0xb3f1457b42b3b3f6L; 0x2115a54234212184L
        ; 0x9c94d625089c9c4aL; 0x1ef0663cee1e1e78L; 0x4322528661434311L
        ; 0xc776fc93b1c7c73bL; 0xfcb32be54ffcfcd7L; 0x0420140824040410L
        ; 0x51b208a2e3515159L; 0x99bcc72f2599995eL; 0x6d4fc4da226d6da9L
        ; 0x0d68391a650d0d34L; 0xfa8335e979fafacfL; 0xdfb684a369dfdf5bL
        ; 0x7ed79bfca97e7ee5L; 0x243db44819242490L; 0x3bc5d776fe3b3becL
        ; 0xab313d4b9aabab96L; 0xce3ed181f0cece1fL; 0x1188552299111144L
        ; 0x8f0c8903838f8f06L; 0x4e4a6b9c044e4e25L; 0xb7d1517366b7b7e6L
        ; 0xeb0b60cbe0ebeb8bL; 0x3cfdcc78c13c3cf0L; 0x817cbf1ffd81813eL
        ; 0x94d4fe354094946aL; 0xf7eb0cf31cf7f7fbL; 0xb9a1676f18b9b9deL
        ; 0x13985f268b13134cL; 0x2c7d9c58512c2cb0L; 0xd3d6b8bb05d3d36bL
        ; 0xe76b5cd38ce7e7bbL; 0x6e57cbdc396e6ea5L; 0xc46ef395aac4c437L
        ; 0x03180f061b03030cL; 0x568a13acdc565645L; 0x441a49885e44440dL
        ; 0x7fdf9efea07f7fe1L; 0xa921374f88a9a99eL; 0x2a4d8254672a2aa8L
        ; 0xbbb16d6b0abbbbd6L; 0xc146e29f87c1c123L; 0x53a202a6f1535351L
        ; 0xdcae8ba572dcdc57L; 0x0b582716530b0b2cL; 0x9d9cd327019d9d4eL
        ; 0x6c47c1d82b6c6cadL; 0x3195f562a43131c4L; 0x7487b9e8f37474cdL
        ; 0xf6e309f115f6f6ffL; 0x460a438c4c464605L; 0xac092645a5acac8aL
        ; 0x893c970fb589891eL; 0x14a04428b4141450L; 0xe15b42dfbae1e1a3L
        ; 0x16b04e2ca6161658L; 0x3acdd274f73a3ae8L; 0x696fd0d2066969b9L
        ; 0x09482d1241090924L; 0x70a7ade0d77070ddL; 0xb6d954716fb6b6e2L
        ; 0xd0ceb7bd1ed0d067L; 0xed3b7ec7d6eded93L; 0xcc2edb85e2cccc17L
        ; 0x422a578468424215L; 0x98b4c22d2c98985aL; 0xa4490e55eda4a4aaL
        ; 0x285d8850752828a0L; 0x5cda31b8865c5c6dL; 0xf8933fed6bf8f8c7L
        ; 0x8644a411c2868622L |]
     ; [| 0x6018c07830d81818L; 0x8c2305af46262323L; 0x3fc67ef991b8c6c6L
        ; 0x87e8136fcdfbe8e8L; 0x26874ca113cb8787L; 0xdab8a9626d11b8b8L
        ; 0x0401080502090101L; 0x214f426e9e0d4f4fL; 0xd836adee6c9b3636L
        ; 0xa2a6590451ffa6a6L; 0x6fd2debdb90cd2d2L; 0xf3f5fb06f70ef5f5L
        ; 0xf979ef80f2967979L; 0xa16f5fcede306f6fL; 0x7e91fcef3f6d9191L
        ; 0x5552aa07a4f85252L; 0x9d6027fdc0476060L; 0xcabc89766535bcbcL
        ; 0x569baccd2b379b9bL; 0x028e048c018a8e8eL; 0xb6a371155bd2a3a3L
        ; 0x300c603c186c0c0cL; 0xf17bff8af6847b7bL; 0xd435b5e16a803535L
        ; 0x741de8693af51d1dL; 0xa7e05347ddb3e0e0L; 0x7bd7f6acb321d7d7L
        ; 0x2fc25eed999cc2c2L; 0xb82e6d965c432e2eL; 0x314b627a96294b4bL
        ; 0xdffea321e15dfefeL; 0x41578216aed55757L; 0x5415a8412abd1515L
        ; 0xc1779fb6eee87777L; 0xdc37a5eb6e923737L; 0xb3e57b56d79ee5e5L
        ; 0x469f8cd923139f9fL; 0xe7f0d317fd23f0f0L; 0x354a6a7f94204a4aL
        ; 0x4fda9e95a944dadaL; 0x7d58fa25b0a25858L; 0x03c906ca8fcfc9c9L
        ; 0xa429558d527c2929L; 0x280a5022145a0a0aL; 0xfeb1e14f7f50b1b1L
        ; 0xbaa0691a5dc9a0a0L; 0xb16b7fdad6146b6bL; 0x2e855cab17d98585L
        ; 0xcebd8173673cbdbdL; 0x695dd234ba8f5d5dL; 0x4010805020901010L
        ; 0xf7f4f303f507f4f4L; 0x0bcb16c08bddcbcbL; 0xf83eedc67cd33e3eL
        ; 0x140528110a2d0505L; 0x81671fe6ce786767L; 0xb7e47353d597e4e4L
        ; 0x9c2725bb4e022727L; 0x1941325882734141L; 0x168b2c9d0ba78b8bL
        ; 0xa6a7510153f6a7a7L; 0xe97dcf94fab27d7dL; 0x6e95dcfb37499595L
        ; 0x47d88e9fad56d8d8L; 0xcbfb8b30eb70fbfbL; 0x9fee2371c1cdeeeeL
        ; 0xed7cc791f8bb7c7cL; 0x856617e3cc716666L; 0x53dda68ea77bddddL
        ; 0x5c17b84b2eaf1717L; 0x014702468e454747L; 0x429e84dc211a9e9eL
        ; 0x0fca1ec589d4cacaL; 0xb42d75995a582d2dL; 0xc6bf9179632ebfbfL
        ; 0x1c07381b0e3f0707L; 0x8ead012347acadadL; 0x755aea2fb4b05a5aL
        ; 0x36836cb51bef8383L; 0xcc3385ff66b63333L; 0x91633ff2c65c6363L
        ; 0x0802100a04120202L; 0x92aa39384993aaaaL; 0xd971afa8e2de7171L
        ; 0x07c80ecf8dc6c8c8L; 0x6419c87d32d11919L; 0x39497270923b4949L
        ; 0x43d9869aaf5fd9d9L; 0xeff2c31df931f2f2L; 0xabe34b48dba8e3e3L
        ; 0x715be22ab6b95b5bL; 0x1a8834920dbc8888L; 0x529aa4c8293e9a9aL
        ; 0x98262dbe4c0b2626L; 0xc8328dfa64bf3232L; 0xfab0e94a7d59b0b0L
        ; 0x83e91b6acff2e9e9L; 0x3c0f78331e770f0fL; 0x73d5e6a6b733d5d5L
        ; 0x3a8074ba1df48080L; 0xc2be997c6127bebeL; 0x13cd26de87ebcdcdL
        ; 0xd034bde468893434L; 0x3d487a7590324848L; 0xdbffab24e354ffffL
        ; 0xf57af78ff48d7a7aL; 0x7a90f4ea3d649090L; 0x615fc23ebe9d5f5fL
        ; 0x80201da0403d2020L; 0xbd6867d5d00f6868L; 0x681ad07234ca1a1aL
        ; 0x82ae192c41b7aeaeL; 0xeab4c95e757db4b4L; 0x4d549a19a8ce5454L
        ; 0x7693ece53b7f9393L; 0x88220daa442f2222L; 0x8d6407e9c8636464L
        ; 0xe3f1db12ff2af1f1L; 0xd173bfa2e6cc7373L; 0x4812905a24821212L
        ; 0x1d403a5d807a4040L; 0x2008402810480808L; 0x2bc356e89b95c3c3L
        ; 0x97ec337bc5dfececL; 0x4bdb9690ab4ddbdbL; 0xbea1611f5fc0a1a1L
        ; 0x0e8d1c8307918d8dL; 0xf43df5c97ac83d3dL; 0x6697ccf1335b9797L
        ; 0x0000000000000000L; 0x1bcf36d483f9cfcfL; 0xac2b4587566e2b2bL
        ; 0xc57697b3ece17676L; 0x328264b019e68282L; 0x7fd6fea9b128d6d6L
        ; 0x6c1bd87736c31b1bL; 0xeeb5c15b7774b5b5L; 0x86af112943beafafL
        ; 0xb56a77dfd41d6a6aL; 0x5d50ba0da0ea5050L; 0x0945124c8a574545L
        ; 0xebf3cb18fb38f3f3L; 0xc0309df060ad3030L; 0x9bef2b74c3c4efefL
        ; 0xfc3fe5c37eda3f3fL; 0x4955921caac75555L; 0xb2a2791059dba2a2L
        ; 0x8fea0365c9e9eaeaL; 0x89650fecca6a6565L; 0xd2bab9686903babaL
        ; 0xbc2f65935e4a2f2fL; 0x27c04ee79d8ec0c0L; 0x5fdebe81a160dedeL
        ; 0x701ce06c38fc1c1cL; 0xd3fdbb2ee746fdfdL; 0x294d52649a1f4d4dL
        ; 0x7292e4e039769292L; 0xc9758fbceafa7575L; 0x1806301e0c360606L
        ; 0x128a249809ae8a8aL; 0xf2b2f940794bb2b2L; 0xbfe66359d185e6e6L
        ; 0x380e70361c7e0e0eL; 0x7c1ff8633ee71f1fL; 0x956237f7c4556262L
        ; 0x77d4eea3b53ad4d4L; 0x9aa829324d81a8a8L; 0x6296c4f431529696L
        ; 0xc3f99b3aef62f9f9L; 0x33c566f697a3c5c5L; 0x942535b14a102525L
        ; 0x7959f220b2ab5959L; 0x2a8454ae15d08484L; 0xd572b7a7e4c57272L
        ; 0xe439d5dd72ec3939L; 0x2d4c5a6198164c4cL; 0x655eca3bbc945e5eL
        ; 0xfd78e785f09f7878L; 0xe038ddd870e53838L; 0x0a8c148605988c8cL
        ; 0x63d1c6b2bf17d1d1L; 0xaea5410b57e4a5a5L; 0xafe2434dd9a1e2e2L
        ; 0x99612ff8c24e6161L; 0xf6b3f1457b42b3b3L; 0x842115a542342121L
        ; 0x4a9c94d625089c9cL; 0x781ef0663cee1e1eL; 0x1143225286614343L
        ; 0x3bc776fc93b1c7c7L; 0xd7fcb32be54ffcfcL; 0x1004201408240404L
        ; 0x5951b208a2e35151L; 0x5e99bcc72f259999L; 0xa96d4fc4da226d6dL
        ; 0x340d68391a650d0dL; 0xcffa8335e979fafaL; 0x5bdfb684a369dfdfL
        ; 0xe57ed79bfca97e7eL; 0x90243db448192424L; 0xec3bc5d776fe3b3bL
        ; 0x96ab313d4b9aababL; 0x1fce3ed181f0ceceL; 0x4411885522991111L
        ; 0x068f0c8903838f8fL; 0x254e4a6b9c044e4eL; 0xe6b7d1517366b7b7L
        ; 0x8beb0b60cbe0ebebL; 0xf03cfdcc78c13c3cL; 0x3e817cbf1ffd8181L
        ; 0x6a94d4fe35409494L; 0xfbf7eb0cf31cf7f7L; 0xdeb9a1676f18b9b9L
        ; 0x4c13985f268b1313L; 0xb02c7d9c58512c2cL; 0x6bd3d6b8bb05d3d3L
        ; 0xbbe76b5cd38ce7e7L; 0xa56e57cbdc396e6eL; 0x37c46ef395aac4c4L
        ; 0x0c03180f061b0303L; 0x45568a13acdc5656L; 0x0d441a49885e4444L
        ; 0xe17fdf9efea07f7fL; 0x9ea921374f88a9a9L; 0xa82a4d8254672a2aL
        ; 0xd6bbb16d6b0abbbbL; 0x23c146e29f87c1c1L; 0x5153a202a6f15353L
        ; 0x57dcae8ba572dcdcL; 0x2c0b582716530b0bL; 0x4e9d9cd327019d9dL
        ; 0xad6c47c1d82b6c6cL; 0xc43195f562a43131L; 0xcd7487b9e8f37474L
        ; 0xfff6e309f115f6f6L; 0x05460a438c4c4646L; 0x8aac092645a5acacL
        ; 0x1e893c970fb58989L; 0x5014a04428b41414L; 0xa3e15b42dfbae1e1L
        ; 0x5816b04e2ca61616L; 0xe83acdd274f73a3aL; 0xb9696fd0d2066969L
        ; 0x2409482d12410909L; 0xdd70a7ade0d77070L; 0xe2b6d954716fb6b6L
        ; 0x67d0ceb7bd1ed0d0L; 0x93ed3b7ec7d6ededL; 0x17cc2edb85e2ccccL
        ; 0x15422a5784684242L; 0x5a98b4c22d2c9898L; 0xaaa4490e55eda4a4L
        ; 0xa0285d8850752828L; 0x6d5cda31b8865c5cL; 0xc7f8933fed6bf8f8L
        ; 0x228644a411c28686L |]
     ; [| 0x186018c07830d818L; 0x238c2305af462623L; 0xc63fc67ef991b8c6L
        ; 0xe887e8136fcdfbe8L; 0x8726874ca113cb87L; 0xb8dab8a9626d11b8L
        ; 0x0104010805020901L; 0x4f214f426e9e0d4fL; 0x36d836adee6c9b36L
        ; 0xa6a2a6590451ffa6L; 0xd26fd2debdb90cd2L; 0xf5f3f5fb06f70ef5L
        ; 0x79f979ef80f29679L; 0x6fa16f5fcede306fL; 0x917e91fcef3f6d91L
        ; 0x525552aa07a4f852L; 0x609d6027fdc04760L; 0xbccabc89766535bcL
        ; 0x9b569baccd2b379bL; 0x8e028e048c018a8eL; 0xa3b6a371155bd2a3L
        ; 0x0c300c603c186c0cL; 0x7bf17bff8af6847bL; 0x35d435b5e16a8035L
        ; 0x1d741de8693af51dL; 0xe0a7e05347ddb3e0L; 0xd77bd7f6acb321d7L
        ; 0xc22fc25eed999cc2L; 0x2eb82e6d965c432eL; 0x4b314b627a96294bL
        ; 0xfedffea321e15dfeL; 0x5741578216aed557L; 0x155415a8412abd15L
        ; 0x77c1779fb6eee877L; 0x37dc37a5eb6e9237L; 0xe5b3e57b56d79ee5L
        ; 0x9f469f8cd923139fL; 0xf0e7f0d317fd23f0L; 0x4a354a6a7f94204aL
        ; 0xda4fda9e95a944daL; 0x587d58fa25b0a258L; 0xc903c906ca8fcfc9L
        ; 0x29a429558d527c29L; 0x0a280a5022145a0aL; 0xb1feb1e14f7f50b1L
        ; 0xa0baa0691a5dc9a0L; 0x6bb16b7fdad6146bL; 0x852e855cab17d985L
        ; 0xbdcebd8173673cbdL; 0x5d695dd234ba8f5dL; 0x1040108050209010L
        ; 0xf4f7f4f303f507f4L; 0xcb0bcb16c08bddcbL; 0x3ef83eedc67cd33eL
        ; 0x05140528110a2d05L; 0x6781671fe6ce7867L; 0xe4b7e47353d597e4L
        ; 0x279c2725bb4e0227L; 0x4119413258827341L; 0x8b168b2c9d0ba78bL
        ; 0xa7a6a7510153f6a7L; 0x7de97dcf94fab27dL; 0x956e95dcfb374995L
        ; 0xd847d88e9fad56d8L; 0xfbcbfb8b30eb70fbL; 0xee9fee2371c1cdeeL
        ; 0x7ced7cc791f8bb7cL; 0x66856617e3cc7166L; 0xdd53dda68ea77bddL
        ; 0x175c17b84b2eaf17L; 0x47014702468e4547L; 0x9e429e84dc211a9eL
        ; 0xca0fca1ec589d4caL; 0x2db42d75995a582dL; 0xbfc6bf9179632ebfL
        ; 0x071c07381b0e3f07L; 0xad8ead012347acadL; 0x5a755aea2fb4b05aL
        ; 0x8336836cb51bef83L; 0x33cc3385ff66b633L; 0x6391633ff2c65c63L
        ; 0x020802100a041202L; 0xaa92aa39384993aaL; 0x71d971afa8e2de71L
        ; 0xc807c80ecf8dc6c8L; 0x196419c87d32d119L; 0x4939497270923b49L
        ; 0xd943d9869aaf5fd9L; 0xf2eff2c31df931f2L; 0xe3abe34b48dba8e3L
        ; 0x5b715be22ab6b95bL; 0x881a8834920dbc88L; 0x9a529aa4c8293e9aL
        ; 0x2698262dbe4c0b26L; 0x32c8328dfa64bf32L; 0xb0fab0e94a7d59b0L
        ; 0xe983e91b6acff2e9L; 0x0f3c0f78331e770fL; 0xd573d5e6a6b733d5L
        ; 0x803a8074ba1df480L; 0xbec2be997c6127beL; 0xcd13cd26de87ebcdL
        ; 0x34d034bde4688934L; 0x483d487a75903248L; 0xffdbffab24e354ffL
        ; 0x7af57af78ff48d7aL; 0x907a90f4ea3d6490L; 0x5f615fc23ebe9d5fL
        ; 0x2080201da0403d20L; 0x68bd6867d5d00f68L; 0x1a681ad07234ca1aL
        ; 0xae82ae192c41b7aeL; 0xb4eab4c95e757db4L; 0x544d549a19a8ce54L
        ; 0x937693ece53b7f93L; 0x2288220daa442f22L; 0x648d6407e9c86364L
        ; 0xf1e3f1db12ff2af1L; 0x73d173bfa2e6cc73L; 0x124812905a248212L
        ; 0x401d403a5d807a40L; 0x0820084028104808L; 0xc32bc356e89b95c3L
        ; 0xec97ec337bc5dfecL; 0xdb4bdb9690ab4ddbL; 0xa1bea1611f5fc0a1L
        ; 0x8d0e8d1c8307918dL; 0x3df43df5c97ac83dL; 0x976697ccf1335b97L
        ; 0x0000000000000000L; 0xcf1bcf36d483f9cfL; 0x2bac2b4587566e2bL
        ; 0x76c57697b3ece176L; 0x82328264b019e682L; 0xd67fd6fea9b128d6L
        ; 0x1b6c1bd87736c31bL; 0xb5eeb5c15b7774b5L; 0xaf86af112943beafL
        ; 0x6ab56a77dfd41d6aL; 0x505d50ba0da0ea50L; 0x450945124c8a5745L
        ; 0xf3ebf3cb18fb38f3L; 0x30c0309df060ad30L; 0xef9bef2b74c3c4efL
        ; 0x3ffc3fe5c37eda3fL; 0x554955921caac755L; 0xa2b2a2791059dba2L
        ; 0xea8fea0365c9e9eaL; 0x6589650fecca6a65L; 0xbad2bab9686903baL
        ; 0x2fbc2f65935e4a2fL; 0xc027c04ee79d8ec0L; 0xde5fdebe81a160deL
        ; 0x1c701ce06c38fc1cL; 0xfdd3fdbb2ee746fdL; 0x4d294d52649a1f4dL
        ; 0x927292e4e0397692L; 0x75c9758fbceafa75L; 0x061806301e0c3606L
        ; 0x8a128a249809ae8aL; 0xb2f2b2f940794bb2L; 0xe6bfe66359d185e6L
        ; 0x0e380e70361c7e0eL; 0x1f7c1ff8633ee71fL; 0x62956237f7c45562L
        ; 0xd477d4eea3b53ad4L; 0xa89aa829324d81a8L; 0x966296c4f4315296L
        ; 0xf9c3f99b3aef62f9L; 0xc533c566f697a3c5L; 0x25942535b14a1025L
        ; 0x597959f220b2ab59L; 0x842a8454ae15d084L; 0x72d572b7a7e4c572L
        ; 0x39e439d5dd72ec39L; 0x4c2d4c5a6198164cL; 0x5e655eca3bbc945eL
        ; 0x78fd78e785f09f78L; 0x38e038ddd870e538L; 0x8c0a8c148605988cL
        ; 0xd163d1c6b2bf17d1L; 0xa5aea5410b57e4a5L; 0xe2afe2434dd9a1e2L
        ; 0x6199612ff8c24e61L; 0xb3f6b3f1457b42b3L; 0x21842115a5423421L
        ; 0x9c4a9c94d625089cL; 0x1e781ef0663cee1eL; 0x4311432252866143L
        ; 0xc73bc776fc93b1c7L; 0xfcd7fcb32be54ffcL; 0x0410042014082404L
        ; 0x515951b208a2e351L; 0x995e99bcc72f2599L; 0x6da96d4fc4da226dL
        ; 0x0d340d68391a650dL; 0xfacffa8335e979faL; 0xdf5bdfb684a369dfL
        ; 0x7ee57ed79bfca97eL; 0x2490243db4481924L; 0x3bec3bc5d776fe3bL
        ; 0xab96ab313d4b9aabL; 0xce1fce3ed181f0ceL; 0x1144118855229911L
        ; 0x8f068f0c8903838fL; 0x4e254e4a6b9c044eL; 0xb7e6b7d1517366b7L
        ; 0xeb8beb0b60cbe0ebL; 0x3cf03cfdcc78c13cL; 0x813e817cbf1ffd81L
        ; 0x946a94d4fe354094L; 0xf7fbf7eb0cf31cf7L; 0xb9deb9a1676f18b9L
        ; 0x134c13985f268b13L; 0x2cb02c7d9c58512cL; 0xd36bd3d6b8bb05d3L
        ; 0xe7bbe76b5cd38ce7L; 0x6ea56e57cbdc396eL; 0xc437c46ef395aac4L
        ; 0x030c03180f061b03L; 0x5645568a13acdc56L; 0x440d441a49885e44L
        ; 0x7fe17fdf9efea07fL; 0xa99ea921374f88a9L; 0x2aa82a4d8254672aL
        ; 0xbbd6bbb16d6b0abbL; 0xc123c146e29f87c1L; 0x535153a202a6f153L
        ; 0xdc57dcae8ba572dcL; 0x0b2c0b582716530bL; 0x9d4e9d9cd327019dL
        ; 0x6cad6c47c1d82b6cL; 0x31c43195f562a431L; 0x74cd7487b9e8f374L
        ; 0xf6fff6e309f115f6L; 0x4605460a438c4c46L; 0xac8aac092645a5acL
        ; 0x891e893c970fb589L; 0x145014a04428b414L; 0xe1a3e15b42dfbae1L
        ; 0x165816b04e2ca616L; 0x3ae83acdd274f73aL; 0x69b9696fd0d20669L
        ; 0x092409482d124109L; 0x70dd70a7ade0d770L; 0xb6e2b6d954716fb6L
        ; 0xd067d0ceb7bd1ed0L; 0xed93ed3b7ec7d6edL; 0xcc17cc2edb85e2ccL
        ; 0x4215422a57846842L; 0x985a98b4c22d2c98L; 0xa4aaa4490e55eda4L
        ; 0x28a0285d88507528L; 0x5c6d5cda31b8865cL; 0xf8c7f8933fed6bf8L
        ; 0x86228644a411c286L |] |]

  let whirlpool_do_chunk : type a.
      be64_to_cpu:(a -> int -> int64) -> ctx -> a -> int -> unit =
   fun ~be64_to_cpu ctx buf off ->
    let key = Array.init 2 (fun _ -> Array.make 8 Int64.zero) in
    let state = Array.init 2 (fun _ -> Array.make 8 Int64.zero) in
    let m = ref 0 in
    let rc =
      [| 0x1823c6e887b8014fL; 0x36a6d2f5796f9152L; 0x60bc9b8ea30c7b35L
       ; 0x1de0d7c22e4bfe57L; 0x157737e59ff04adaL; 0x58c9290ab1a06b85L
       ; 0xbd5d10f4cb3e0567L; 0xe427418ba77d95d8L; 0xfbee7c66dd17479eL
       ; 0xca2dbf07ad5a8333L |]
    in
    for i = 0 to 7 do
      key.(0).(i) <- ctx.h.(i) ;
      let off = off + (i * 8) in
      state.(0).(i) <- Int64.(be64_to_cpu buf off lxor ctx.h.(i)) ;
      ctx.h.(i) <- state.(0).(i)
    done ;
    let wp_op src shift =
      let mask v = Int64.(to_int (v land 0xffL)) in
      let get_k i =
        k.(i).(mask
                 (Int64.shift_right src.((shift + 8 - i) land 7) (56 - (8 * i))))
      in
      List.fold_left Int64.logxor Int64.zero (List.init 8 get_k)
    in
    for i = 0 to 9 do
      let m0, m1 = !m, !m lxor 1 in
      let upd_key i = key.(m1).(i) <- wp_op key.(m0) i in
      let upd_state i =
        state.(m1).(i) <- Int64.(wp_op state.(m0) i lxor key.(m1).(i))
      in
      for i = 0 to 7 do
        upd_key i
      done ;
      key.(m1).(0) <- Int64.(key.(m1).(0) lxor rc.(i)) ;
      for i = 0 to 7 do
        upd_state i
      done ;
      m := !m lxor 1
    done ;
    let upd_hash i = Int64.(ctx.h.(i) <- ctx.h.(i) lxor state.(0).(i)) in
    for i = 0 to 7 do
      upd_hash i
    done ;
    ()

  let feed : type a.
         blit:(a -> int -> By.t -> int -> int -> unit)
      -> be64_to_cpu:(a -> int -> int64)
      -> ctx
      -> a
      -> int
      -> int
      -> unit =
   fun ~blit ~be64_to_cpu ctx buf off len ->
    let idx = ref Int64.(to_int (ctx.size land 0x3FL)) in
    let len = ref len in
    let off = ref off in
    let to_fill = 64 - !idx in
    ctx.size <- Int64.add ctx.size (Int64.of_int !len) ;
    if !idx <> 0 && !len >= to_fill then (
      blit buf !off ctx.b !idx to_fill ;
      whirlpool_do_chunk ~be64_to_cpu:By.be64_to_cpu ctx ctx.b 0 ;
      len := !len - to_fill ;
      off := !off + to_fill ;
      idx := 0 ) ;
    while !len >= 64 do
      whirlpool_do_chunk ~be64_to_cpu ctx buf !off ;
      len := !len - 64 ;
      off := !off + 64
    done ;
    if !len <> 0 then blit buf !off ctx.b !idx !len ;
    ()

  let unsafe_feed_bytes = feed ~blit:By.blit ~be64_to_cpu:By.be64_to_cpu

  let unsafe_feed_bigstring =
    feed ~blit:By.blit_from_bigstring ~be64_to_cpu:Bi.be64_to_cpu

  let unsafe_get ctx =
    let index = Int64.(to_int (ctx.size land 0x3FL)) + 1 in
    By.set ctx.b (index - 1) '\x80' ;
    if index > 32 then (
      By.fill ctx.b index (64 - index) '\x00' ;
      whirlpool_do_chunk ~be64_to_cpu:By.be64_to_cpu ctx ctx.b 0 ;
      By.fill ctx.b 0 56 '\x00' )
    else By.fill ctx.b index (56 - index) '\x00' ;
    By.cpu_to_be64 ctx.b 56 Int64.(ctx.size lsl 3) ;
    whirlpool_do_chunk ~be64_to_cpu:By.be64_to_cpu ctx ctx.b 0 ;
    let res = By.create (8 * 8) in
    for i = 0 to 7 do
      By.cpu_to_be64 res (i * 8) ctx.h.(i)
    done ;
    res
end
