trigger ControlAgendasDuplicadas on Agenda__c (before insert, before update) {

    Set<Id> centros = new Set<Id>();
    Set<Id> especialidades = new Set<Id>();
    for (Agenda__c a : Trigger.new) {
        centros.add(a.Centro__c);
        especialidades.add(a.Especialidad__c);
    }

    List<Agenda__c> existingAgendas = [
        SELECT Id, Especialidad__c, Centro__c, Dias_Disponibles__c, Fecha_Inicio__c, Fecha_Final__c
        FROM Agenda__c
        WHERE Especialidad__c IN :especialidades
        AND Centro__c IN :centros
    ];

    Map<String, List<Agenda__c>> existingAgendaMap = new Map<String, List<Agenda__c>>();
    for (Agenda__c agenda : existingAgendas) {
        for (String dia : agenda.Dias_Disponibles__c.split(';')) {
            String key = agenda.Centro__c + ':' + agenda.Especialidad__c + ':' + dia.trim();
             if (!existingAgendaMap.containsKey(key)) {
                existingAgendaMap.put(key, new List<Agenda__c>());
            }
            existingAgendaMap.get(key).add(agenda);
        }
    }

    for (Agenda__c agenda : Trigger.new) {
        for (String dia : agenda.Dias_Disponibles__c.split(';')) {
            String key = agenda.Centro__c + ':' + agenda.Especialidad__c + ':' + dia.trim();
            if (existingAgendaMap.containsKey(key)) {
                for (Agenda__c existente : existingAgendaMap.get(key)) {
                    if (Trigger.isUpdate && existente.Id == agenda.Id) continue;
                    if (agenda.Fecha_Inicio__c <= existente.Fecha_Final__c && agenda.Fecha_Final__c >= existente.Fecha_Inicio__c) {
                        agenda.addError('Ya existe una agenda para esta especialidad, centro y día con un rango de fechas que se solapa.');
                        break;
                    }
                }
            }
        }
    }
}