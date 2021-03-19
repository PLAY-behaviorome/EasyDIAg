## Parameters
pri_col_name = 'pri_col'
# rel column has multiple coders
rel_col_name_list = %w[rel_col]
block_col_name = 'relblocks'
codes_to_check = %w(code1 code2)
input_folder = '~/Desktop/input'
output_folder = File.expand_path('~/Desktop')

time_buffer = 500

pri_suffix = '_R1'
rel_suffix = '_R2'

delimiter = "\t"

## Body
require 'Datavyu_API.rb'

input_path = File.expand_path(input_folder)
infiles = Dir.chdir(input_path) { Dir.glob('*.opf') }

codes_to_check.each do |code|
  outfilename = code + '.txt'
  output_file = File.join(File.expand_path(output_folder),outfilename)
  outfile = File.new(output_file,'w')
  data = []

  infiles.each do |infile|
    $db, $pj = load_db(File.join(input_path,infile))

    # get the rel column name in the current spreadsheet
    rel_col_name = get_column_list.select{ |col_name|
      rel_col_name_list.include?(col_name)}.first

    pri_col = get_column(pri_col_name)
    rel_col = get_column(rel_col_name)
    block_col = get_column(block_col_name)

    pri_col.cells.each do |pc|
      next unless block_col.cells.map{ |bc| bc.contains(pc) }.any?
      data_row = code + pri_suffix + delimiter + (pc.onset - time_buffer).to_s + delimiter +
        (pc.offset + time_buffer).to_s + delimiter + pc.get_code(code) + delimiter +
        infile
      data << data_row
    end

    rel_col.cells.each do |rc|
      next unless block_col.cells.map{ |bc| bc.contains(rc) }.any?
      data_row = code + rel_suffix + delimiter + (rc.onset - time_buffer).to_s + delimiter +
        (rc.offset + time_buffer).to_s + delimiter + rc.get_code(code) + delimiter +
        infile
      data << data_row
    end
  end
  outfile.puts data
  outfile.close
end
