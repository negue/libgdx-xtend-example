package de.negue.libgdx.xtend

import com.badlogic.gdx.Game

class XtendGame extends Game {

  override create() {
    setScreen(new XtendScreen(this))
  }
}