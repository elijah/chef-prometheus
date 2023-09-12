# Credit https://stackoverflow.com/a/30225093 , with minor changes
class ::Hash
  def deep_merge(rhs)
    overwrite = [nil, :nil, :undefined]
    fn = proc { |_, l, r|
      Hash === l && Hash === r ? l.merge(r, &fn) :
        Array === l && Array === r ? l | r :
        overwrite.include?(r) ? l : r
    }
    merge(rhs.to_h, &fn)
  end
end
