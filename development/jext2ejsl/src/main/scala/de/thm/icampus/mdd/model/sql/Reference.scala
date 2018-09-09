package de.thm.icampus.mdd.model.sql

/**
 * Created by alexheinz1110 on 14.08.15.
 */
 class Reference {
  def setEntityName(extName: String): Unit={
    this.entity = this.entity.replaceFirst(extName+"_","")
    this.reference =  reference.map(t => entity + "."+t).toList
  }

  var attribute: List[String]= List.empty[String]
  var entity: String=""
  var reference: List[String]= List.empty[String]
  var lower: String  ="0"
  var upper: String = "-1"
  def this (attribute: List[String], entity: String, reference: List[String], lower: String  ="0", upper: String = "-1"){
    this()
    this.attribute = attribute
    this.entity = entity
    this.reference = reference
    this.lower = lower
    this.upper = upper
  }
}
