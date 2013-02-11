{% set logger = classes.get(table.getOptions().get('crud_logger')) %}
    <table class="table table-condensed table-hover">
        <caption><h3>{$i18n->_('Tracking')}</h3></caption>
        <thead>
            <tr>
                <th>#</th>
                <th>{$i18n->_('User')}</th>
                <th>{$i18n->_('EventType')}</th>
                <th>{$i18n->_('Date')}</th>
            </tr>
        </thead>
        <tbody>
            {$i = 1}
            {foreach ${{ logger.getName().pluralize() }} as $log}
                <tr>
                     <td>{$i++}</td>
                     <td>{$users[$log->getIdUser()]}</td>
                     <td>{$i18n->_($log->getEventTypeName())}</td>
                     <td>{$log->getDateLog()}</td> 
                </tr>
            {/foreach}
        </tbody>
    </table>
    <div class="form-actions">
	    <a class="btn" href="javascript:history.go(-1)">{$i18n->_('Back')}</a>
    </div>
    