package de.thm.icampus.mdd.model.extensions
import de.thm.icampus.mdd.model.sql.{Entity}

class IndexPage extends DynamicPage {
  var  name: String =""
  var entity: String=""
  var globalParamNames: Set[JParamGroup] = Set.empty[JParamGroup]
  var representationColumns: Set[String] = Set.empty[String]
  var  filters: Set[String] = Set.empty[String]
  var entityObjekt :Entity = null
  def this (name: String, entity: String, globalParamNames: Set[JParamGroup] = Set.empty[JParamGroup],
            representationColumns: Set[String] = Set.empty[String],filters: Set[String] = Set.empty[String]){
    this()
    this.name = name
    this.entity = entity
    this.globalParamNames = globalParamNames
    this.representationColumns = representationColumns
    this.filters = filters


  }

  def verifiedField() = {
    val attr = this.entityObjekt.getAllAttribute()
    this.representationColumns =  this.representationColumns.filter(t => attr.contains(t))
    this.filters = this.filters.filter(t => attr.contains(t))
  }
  override def equals (obj:Any): Boolean={
    obj match{
      case f : IndexPage =>{
        if(f.name == this.name){
          if(f.entity != this.entity){
            f.name = f.name + 1
            return false
          }
          this.filters = f.filters.|(this.filters)
          this.representationColumns = f.representationColumns.|(this.representationColumns)
          this.globalParamNames = f.globalParamNames.|(this.globalParamNames)
          f.globalParamNames = this.globalParamNames
          f.representationColumns = this.representationColumns
          f.filters = this.filters

          return true
        }

      }
      case _ => return false
    }
    return false
  }

  def setEntityOb(entities:List[Entity]): Unit ={
    for(r <- entities){
      if(r.name == this.entity){
        this.entityObjekt = r
        verifiedField()
        return
      }
    }
  }
  override def hashCode: Int = {
    val prime = this.getClass.hashCode()
    prime  * this.name.hashCode + this.entity.hashCode  + this.filters.hashCode()
  }
}
