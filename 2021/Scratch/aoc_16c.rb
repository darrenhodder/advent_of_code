transmission = DATA.read    # Hex transmission as its received
@bits = ""                   # the transmission converted to binary
@versions = []               # record all @versions in transmission
@literals = []
@sub_packets = []
@packets = []


# convert Hex transmission to binary
transmission.each_char do |ch|
    # convert hex to binary, and ensure digits are four in length with padding
    @bits += ch.to_i(16).to_s(2).rjust(4,"0")
end

def process(bits)

    version = 0
    type = 0
    version = bits[0..2].to_i(2)
    type = bits[3..5].to_i(2)

    @versions << version

    bits.slice!(0..5)

    if type == 4
        last_char = false
        literal = ""
        
        while last_char == false do
            bits[0] == "0" ? last_char = true : nil
            literal += bits[1..4]
            bits.slice!(0..4)
        end
        @literals << literal
        @packets << [version, version, literal]

    else
        length_type = bits[0] # the first character after the header is the length indicator, one digit
        bits.slice!(0)

        if length_type == "0" # the next 15 @bits is a number that represents the total length in @bits of the contained sub-packets
            total_length = bits[0..14].to_i(2)
            bits.slice!(0..14)
            @sub_packets << bits[0..(total_length-1)]
            bits.slice!(0..(total_length-1))
        else # type is 1, the next 11 @bits represent the number of sub-packets contained in the packet
            num = bits[0..10].to_i(2)
            bits.slice!(0..10)
            num.times do
                @sub_packets << bits[0..10]
                bits.slice!(0..10)
            end
        end
    end
end

process(@bits)

while @sub_packets.count > 0
    clean_sub_array = []
    @sub_packets.each do |sub|
        unless sub == "" || @sub_packets[0].match(/[1]/) == nil
            clean_sub_array << sub 
        end
    end
    @sub_packets = clean_sub_array.dup
    @sub_packets
    clean_sub_array.each do |new_sub|
        unless new_sub == "" || new_sub == nil
            process(new_sub)   
        end
    end
end

print @versions.sum
__END__
420D5A802122FD25C8CD7CC010B00564D0E4B76C7D5A59C8C014E007325F116C958F2C7D31EB4EDF90A9803B2EB5340924CA002761803317E2B4793006E28C2286440087C5682312D0024B9EF464DF37EFA0CD031802FA00B4B7ED2D6BD2109485E3F3791FDEB3AF0D8802A899E49370012A926A9F8193801531C84F5F573004F803571006A2C46B8280008645C8B91924AD3753002E512400CC170038400A002BCD80A445002440082021DD807C0201C510066670035C00940125D803E170030400B7003C0018660034E6F1801201042575880A5004D9372A520E735C876FD2C3008274D24CDE614A68626D94804D4929693F003531006A1A47C85000084C4586B10D802F5977E88D2DD2898D6F17A614CC0109E9CE97D02D006EC00086C648591740010C8AF14E0E180253673400AA48D15E468A2000ADCCED1A174218D6C017DCFAA4EB2C8C5FA7F21D3F9152012F6C01797FF3B4AE38C32FFE7695C719A6AB5E25080250EE7BB7FEF72E13980553CE932EB26C72A2D26372D69759CC014F005E7E9F4E9FA7D3653FCC879803E200CC678470EC0010E82B11E34080330D211C663004F00101911791179296E7F869F9C017998EF11A1BCA52989F5EA778866008D8023255DFBB7BD2A552B65A98ECFEC51D540209DFF2FF2B9C1B9FE5D6A469F81590079160094CD73D85FD2699C5C9DCF21F0700094A1AC9EDA64AE3D37D34200B7B401596D678A73AFB2D0B1B88057230A42B2BD88E7F9F0C94F1ECB7B0DD393489182F9802D3F875C00DC40010F8911C61F8002111BA1FC2E400BEA5AA0334F9359EA741892D81100B83337BD2DDB4E43B401A800021F19A09C1F1006229C3F8726009E002A12D71B96B8E49BB180273AA722468002CC7B818C01B04F77B39EFDF53973D95ADB5CD921802980199CF4ADAA7B67B3D9ACFBEC4F82D19A4F75DE78002007CD6D1A24455200A0E5C47801559BF58665D80