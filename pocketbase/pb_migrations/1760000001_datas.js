/// <reference path="../pb_data/types.d.ts" />

migrate((app) => {
  const nomes = ["solicitacoes", "comentarios"]

  for (const nome of nomes) {
    const collection = app.findCollectionByNameOrId(nome)
    collection.fields.add(new AutodateField({
      name: "created",
      onCreate: true,
      onUpdate: false,
    }))
    collection.fields.add(new AutodateField({
      name: "updated",
      onCreate: true,
      onUpdate: true,
    }))
    app.save(collection)
  }
}, (app) => {
  const nomes = ["solicitacoes", "comentarios"]

  for (const nome of nomes) {
    const collection = app.findCollectionByNameOrId(nome)
    collection.fields.removeByName("created")
    collection.fields.removeByName("updated")
    app.save(collection)
  }
})
