local __bt__ = {
  file= "rootNode",
  type= "",
  data= {
    restart= 1
  },
  children= {
    {
      file= "sequenceNode",
      type= "composites/sequenceNode",
      data= {
        abort= "None"
      },
      children= {
        {
          file= "randomPositionNode",
          type= "actions/randomPositionNode",
          data= {
            center= "0,0,0",
            range= 2
          },
        },
        {
          file= "moveToPositionNode",
          type= "actions/moveToPositionNode",
          data= {
            pos= "RandomPos"
          },
        }
      }
    }
  }
}
return __bt__