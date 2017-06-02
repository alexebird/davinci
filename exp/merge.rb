#!/usr/bin/ruby

require 'yaml'

def merge_2_confs(a, b)
  if a.is_a?(Hash) && b.is_a?(Hash)
    akeys = a.keys
    bkeys = b.keys
    bonly = bkeys - akeys

    a = akeys.map do |k|
      aval = a[k]
      if b.has_key?(k)
        bval = b[k]
        [k, merge_2_confs(aval, bval)]
      else
        [k, aval]
      end
    end.to_h

    #puts a.inspect

    bonly.each do |k|
      #puts k
      a[k] = b[k]
    end

    a
  elsif a.is_a?(Array) && b.is_a?(Array)
    a.concat(b - a)
  else
    b
  end
end

def load_conf(path)
  YAML.load(File.read(path))
end

def merge_confs_helper(conf, rest)
  if rest.empty?
    return conf
  end

  merge_confs_helper(
    merge_2_confs(conf, rest.first),
    rest.drop(1),
  )
end

def merge_confs(confs)
  if confs.empty?
    return ""
  elsif confs.size == 1
    return load_conf(confs.first)
  else
    confs = confs.map {|c| load_conf(c)}
    merge_confs_helper(confs.first, confs.drop(1))
  end
end

puts YAML.dump(merge_confs(ARGV))
